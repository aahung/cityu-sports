//
//  SelectTimeViewController.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "SelectCourtViewController.h"
#import <MBProgressHUD.h>
#import "SimpleAlertViewController.h"
#import "Connector.h"
#import "User.h"
#import "Parser.h"

@interface SelectCourtViewController ()

@end

@implementation SelectCourtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTableViewBackground:self.tableView];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.courts = @{};
    self.times = @[];
    
    [self refresh];
    
    // remove extra rows
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath * selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:true];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.times count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.times objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.courts[self.times[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"time"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"time"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    NSDictionary * court = self.courts[self.times[indexPath.section]][indexPath.item];
    cell.textLabel.text = [court valueForKey:@"courtReadable"];
    cell.detailTextLabel.text = [court valueForKey:@"venueReadable"];
    [cell.imageView setImage:[UIImage imageNamed:[Parser getFacilityImageNameByCode:self.facility]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // deselect row
    NSIndexPath * selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:true];
    }
    
    NSDictionary * court = self.courts[self.times[indexPath.section]][indexPath.item];
    if ([court valueForKey:@"message"] != nil) {
        [SIMPLEALERT showAlertWithTitle:@"Sorry" message:[court valueForKey:@"message"]];
        return;
    }
    if ([court valueForKey:@"date"] == nil || [court valueForKey:@"court"] == nil || [court valueForKey:@"venue"] == nil || [court valueForKey:@"stime"] == nil || [court valueForKey:@"facilityRef"] == nil) {
        [SIMPLEALERT showAlertWithTitle:@"Error" message:[court valueForKey:@"Missed some keys"]];
        return;
    }
    
    [SIMPLEALERT showAlertWithTitle:@"Confirm" message:[NSString stringWithFormat:@"You are going to book %@ at %@", [court valueForKey:@"courtReadable"], [court valueForKey:@"timeReadable"]] defaultTitle:@"Confirm" defaultHandler:^() {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self.bookParameters setObject:[court valueForKey:@"date"] forKey:@"p_date"];
            [self.bookParameters setObject:[court valueForKey:@"court"] forKey:@"p_court"];
            [self.bookParameters setObject:[court valueForKey:@"venue"] forKey:@"p_venue"];
            [self.bookParameters setObject:[court valueForKey:@"stime"] forKey:@"p_stime"];
            [self.bookParameters setObject:[court valueForKey:@"facilityRef"] forKey:@"p_facility_ref"];
            
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.removeFromSuperViewOnHide = true;
            hud.labelText = @"Request confirmation number";
            
            Connector * connector = [[Connector alloc] initWithSessionId:[User getSessionId]];
            [connector makeBooking:[User getEID] password:[User getPassword] bookParameters:self.bookParameters bookReferer:self.bookReferer success:^(NSString * message){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [hud hide:true];
                    [SIMPLEALERT showAlertWithTitle:@"Book result" message:message];
                }];
            } error:^(NSString * message) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    hud.labelText = @"Error";
                    [hud hide:true afterDelay:1.0];
                    [SIMPLEALERT showAlertWithTitle:@"Error" message:message];
                }];
            } partHandler:^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    hud.labelText = @"confirm booking";
                }];
            }];
        }];
    }];
    
}

- (void) refresh {
    [self showProgressWithTitle:@"Requesting court URL..."];
    Connector * connector = [[Connector alloc] initWithSessionId:[User getSessionId]];
    [connector requestCourts:[User getEID] sid:[User getSID] userType:[User getUserType] date:self.date facility: self.facility success:^(NSDictionary * courts, NSMutableDictionary * bookParameters, NSString * bookReferer) {
        self.bookParameters = bookParameters;
        self.bookReferer = bookReferer;
        self.courts = courts;
        self.times = [courts.allKeys sortedArrayUsingSelector:@selector(compare:)];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([self.courts count] == 0) {
                [SIMPLEALERT showAlertWithTitle:@"Sorry" message:@"There is no remaining available" dismissHandler:^{
                    [self performSegueWithIdentifier:@"unwind" sender:self];
                }];
            }
            [self.refreshControl endRefreshing];
            [self finishProgress];
            [self.tableView reloadData];
        }];
    } error:^(NSString * message) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.refreshControl endRefreshing];
            [self cancelProgress];
            [SIMPLEALERT showAlertWithTitle:@"Error" message:message];
        }];
    } partHandler:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self showProgressWithTitle:@"Requesting court list (~5s)..."];
        }];
    }];
}

- (IBAction)unwindToContainerVC:(UIStoryboardSegue *)segue {
    NSLog(@"unwind");
}

@end
