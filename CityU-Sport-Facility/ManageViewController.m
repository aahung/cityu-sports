//
//  ManageViewController.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "ManageViewController.h"
#import "BookingTableViewCell.h"
#import <MBProgressHUD.h>
#import "Connector.h"
#import "User.h"
#import "SimpleAlertViewController.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface ManageViewController ()

@end

@implementation ManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView * bgImageView = [[UIImageView alloc] init];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    self.tableView.backgroundView = bgImageView;
    self.tableView.backgroundView.alpha = 0.15;
    self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    // initial empty label
    self.emptyLabel = [[UILabel alloc] init];
    
    self.emptyLabel.text = @"You have no bookings.\nPlease pull down to refresh,\nor make a booking in \"Booking\".";
    self.emptyLabel.textColor = [UIColor blackColor];
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [self.emptyLabel sizeToFit];
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray * constraints = @[
                              [NSLayoutConstraint constraintWithItem:self.emptyLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                              [NSLayoutConstraint constraintWithItem:self.emptyLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view addSubview:self.emptyLabel];
    [self.view addConstraints:constraints];
    
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"pull to refresh"];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    
    self.books = @[];
    
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.books count] > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.emptyLabel.hidden = true;
        return 1;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.emptyLabel.hidden = false;
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.books count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BookingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"booking"];
    if (cell == nil) {
        cell = [[BookingTableViewCell alloc] init];
    }
    NSDictionary * book = self.books[indexPath.item];
    if ([book valueForKey:@"venue"] != nil) {
        cell.venueLabel.text = [book valueForKey:@"venue"];
    } else {
        cell.venueLabel.text = @"";
    }
    if ([book valueForKey:@"facility"] != nil) {
        cell.facilityLabel.text = [book valueForKey:@"facility"];
    } else {
        cell.facilityLabel.text = @"";
    }
    if ([book valueForKey:@"time"] != nil) {
        cell.timeLabel.text = [book valueForKey:@"time"];
    } else {
        cell.timeLabel.text = @"";
    }
    if ([book valueForKey:@"date"] != nil) {
        cell.dateLabel.text = [book valueForKey:@"date"];
    } else {
        cell.dateLabel.text = @"";
    }
    if ([book valueForKey:@"deadline"] != nil) {
        if ([[book valueForKey:@"deadline"] rangeOfString:@"*"].location == NSNotFound) {
            cell.deadlineLabel.text = [NSString stringWithFormat:@"Pay before: %@", [book valueForKey:@"deadline"]];
        } else {
            cell.deadlineLabel.text = [book valueForKey:@"deadline"];
        }
    } else {
        cell.deadlineLabel.text = @"";
    }
    cell.cancelButton.tag = indexPath.row;
    [cell.cancelButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.cancelButton.enabled = [book valueForKey:@"id"] != nil;
    cell.calendarButton.tag = indexPath.row;
    [cell.calendarButton addTarget:self action:@selector(calendarAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.shareButton.tag = indexPath.row;
    [cell.shareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 190;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self.tableView setEditing:false animated:true];
        [self deleteBooking:indexPath.item sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Cancel" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self.tableView setEditing:false animated:true];
        
        [self deleteBooking:indexPath.item sender:[tableView cellForRowAtIndexPath:indexPath]];
    }];
    
    UITableViewRowAction * calendarAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"+Calendar" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self.tableView setEditing:false animated:true];
        
        [self addToCalendar:indexPath.item];
        
    }];
    
    calendarAction.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255 blue:1.0 alpha:1.0];
    
    return @[deleteAction, calendarAction];
}

- (void) shareAction: (UIButton *)sender {
    NSDictionary * book = self.books[sender.tag];
    NSString *textToShare = [NSString stringWithFormat:@"I made a booking for %@ (%@) on %@ during %@ on CityU Sport Facility App", [book objectForKey:@"facility"], [book objectForKey:@"venue"], [book objectForKey:@"date"], [book objectForKey:@"time"]];
    NSURL *myWebsite = [NSURL URLWithString:@"https://appsto.re/hk/QC6t5.i"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void) calendarAction: (UIButton *)sender {
    [self addToCalendar:sender.tag];
}

- (void) addToCalendar: (NSUInteger)index {
    EKEventStore * eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted && error == nil) {
            EKEvent * event = [EKEvent eventWithEventStore:eventStore];
            
            
            NSDictionary * book = self.books[index];
            
            if ([book valueForKey:@"facility"] != nil) {
                event.title = [book valueForKey:@"facility"];
            } else {
                event.title = @"Exercise";
            }
            
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"(EEE) dd MMMM   yyyy HH:mm";
            NSArray * timeTokens = [[book valueForKey:@"time"] componentsSeparatedByString:@"-"];
            NSString * startTime = [NSString stringWithFormat:@"%@ %@", [book valueForKey:@"date"], timeTokens[0]];
            NSString * endTime = [NSString stringWithFormat:@"%@ %@", [book valueForKey:@"date"], timeTokens[1]];
            
            NSDate * startDate = [dateFormatter dateFromString:startTime];
            NSDate * endDate = [dateFormatter dateFromString:endTime];
            if (startTime != nil && endDate != nil) {
                event.startDate = startDate;
                event.endDate = endDate;
                event.location = [book valueForKey:@"venue"];
                event.notes = [book valueForKey:@"deadline"];
                event.calendar = eventStore.defaultCalendarForNewEvents;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SIMPLEALERT showAlertWithTitle:@"Calendar event" message:[NSString stringWithFormat:@"Title: %@\nDate: %@\nTime: %@\n", event.title, [book valueForKey:@"date"], [book valueForKey:@"time"]] defaultTitle:@"Add and view" defaultHandler:^{
                            NSError * error = nil;
                            [eventStore saveEvent:event span:EKSpanThisEvent commit:true error:&error];
                            if (error == nil) {
                                EKEventViewController *eventViewController = [[EKEventViewController alloc] init];
                                eventViewController.event = event;
                                eventViewController.allowsEditing = YES;
                                eventViewController.modalInPopover = NO;
                                eventViewController.delegate = self;
                                UINavigationController *nav = [[UINavigationController alloc]
                                                               initWithRootViewController:eventViewController];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self presentViewController:nav animated:YES completion:nil];
                                });
                                return;
                            }
                        }];
                    });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SIMPLEALERT showAlertWithTitle:@"Error" message:@"Some unknown error"];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SIMPLEALERT showAlertWithTitle:@"Calendar Access" message:@"Go to Settings - USports to switch on Calendar to create event."];
            });
        }
    }];
}

- (void) deleteAction: (UIButton *)sender {
    [self deleteBooking:sender.tag sender:sender];
}

- (void) deleteBooking: (NSUInteger)index sender: (UIView *)sender {
    NSDictionary * book = self.books[index];
    if ([book valueForKey:@"id"] == nil) {
        [SIMPLEALERT showAlertWithTitle:@"Notice" message:@"You can only cancel this booking in the counter."];
        return;
    }
    [[[SimpleAlertViewController alloc] initWithViewController:self] showActionSheetWithTitle:[NSString stringWithFormat:@"Cancelling %@", [book objectForKey:@"facility"]] message:@"Are you sure you want to cancel this booking? You cannot undo it, and this booking will be released." destructiveTitle:@"I am sure" destructiveHandler:^{
        NSDictionary * book = self.books[index];
        Connector * connector = [[Connector alloc] initWithSessionId:[User getSessionId]];
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide = true;
        hud.labelText = @"Request confirmation";
        [connector deleteBooking:[User getEID] sid:[User getSID] password:[User getPassword] bookingId:[book valueForKey:@"id"] success:^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refresh];
                [hud hide:true];
            });
        } error:^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.labelText = @"Error";
                [hud hide:true afterDelay:1.0];
                [SIMPLEALERT showAlertWithTitle:@"Error" message:@"Cannot delete your bookings."];
            });
        } partHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.labelText = @"confirm delete";
            });
        }];
    } source: sender];
}

- (void) refresh {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = true;
    hud.labelText = @"Request bookings";
    Connector * connector = [[Connector alloc] initWithSessionId:[User getSessionId]];
    [connector requestMyBookings:[User getEID] sid:[User getSID] success:^(AFHTTPRequestOperation * operation, NSArray * books) {
        self.books = books;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [hud hide:true];
            [self.tableView reloadData];
        });
    } error:^(AFHTTPRequestOperation * operation, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            hud.labelText = @"Error";
            [hud hide:true afterDelay:1.0];
            [SIMPLEALERT showAlertWithTitle:@"Error" message:@"Cannot get your bookings."];
        });
    }];
}

- (IBAction)editAction:(id)sender {
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:false animated:true];
        self.editButton.title = @"Edit";
    } else {
        [self.tableView setEditing:true animated:true];
        self.editButton.title = @"Done";
    }
}

- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
