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
#import "SimpleAlertView.h"

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface ManageViewController ()

@end

@implementation ManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView * bgImageView = [[UIImageView alloc] init];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    self.tableView.backgroundView = bgImageView;
    self.tableView.backgroundView.alpha = 0.3;
    self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
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
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 170.0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self.tableView setEditing:false animated:true];
        [self deleteAction:indexPath];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Cancel" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self.tableView setEditing:false animated:true];
        
        [self deleteAction:indexPath];
    }];
    
    UITableViewRowAction * calendarAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"+Calendar" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self.tableView setEditing:false animated:true];
        
        EKEventStore * eventStore = [[EKEventStore alloc] init];
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted && error == nil) {
                EKEvent * event = [EKEvent eventWithEventStore:eventStore];
                
                
                NSDictionary * book = self.books[indexPath.item];
                
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
                    NSError * error = nil;
                    [eventStore saveEvent:event span:EKSpanThisEvent commit:true error:&error];
                    if (error == nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SimpleAlertView showAlertWithTitle:@"Calendar event created" message:[NSString stringWithFormat:@"Date: %@\nTime: %@\nGo to Calendar app and check it out", [book valueForKey:@"date"], [book valueForKey:@"time"]]];
                        });
                        return;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SimpleAlertView showAlertWithTitle:@"Error" message:@"Some unknown error"];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SimpleAlertView showAlertWithTitle:@"Calendar Access" message:@"Go to Settings - USports to switch on Calendar to create event."];
                });
            }
        }];
        
    }];
    
    calendarAction.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255 blue:1.0 alpha:1.0];
    
    return @[deleteAction, calendarAction];
}


- (void) deleteAction: (NSIndexPath *) indexPath {
    NSDictionary * book = self.books[indexPath.item];
    if ([book valueForKey:@"id"] == nil) {
        [SimpleAlertView showAlertWithTitle:@"Notice" message:@"You can only cancel this booking in the counter."];
        return;
    }
    [SimpleAlertView showAlertWithTitle:@"Warning" message:@"Are you sure you want to cancel this booking? You cannot undo it, yes you can, rebook it." destructiveTitle:@"I am sure" destructiveHandler:^(SIAlertView *alert) {
        NSDictionary * book = self.books[indexPath.item];
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
                [SimpleAlertView showAlertWithTitle:@"Error" message:@"Cannot delete your bookings."];
            });
        } partHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.labelText = @"confirm delete";
            });
        }];
    }];
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
            [SimpleAlertView showAlertWithTitle:@"Error" message:@"Cannot get your bookings."];
        });
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
