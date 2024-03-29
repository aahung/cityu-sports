//
//  SelectSportViewController.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "SelectFacilityViewController.h"
#import "SimpleAlertViewController.h"
#import "Connector.h"
#import "User.h"
#import "SelectCourtViewController.h"
#import "Parser.h"

@interface SelectFacilityViewController ()

@end

@implementation SelectFacilityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.facilities = @[];
    
    [self mockPullDown];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.facilities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"facility"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"facility"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    cell.textLabel.text = [Parser getFacilityNameByCode:self.facilities[indexPath.item]];
    [cell.imageView setImage:[UIImage imageNamed:[Parser getFacilityImageNameByCode:self.facilities[indexPath.item]]]];
    return cell;
}

- (void)refresh {
    [self showProgressWithTitle:@"Requesting facility list..."];
    Connector * connector = [[Connector alloc] initWithSessionId:[User getSessionId]];
    [connector requestFacilities:[User getEID] sid:[User getSID] date:[self date] userType:[User getUserType] success:^(NSArray * facilities) {
        self.facilities = facilities;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([self.facilities count] == 0) {
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
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"time"]) {
        SelectCourtViewController * viewController = (SelectCourtViewController *)[segue destinationViewController];
        if (viewController != nil) {
            NSIndexPath * selectedIndexPath = [self.tableView indexPathForSelectedRow];
            viewController.date = self.date;
            viewController.facility = [self.facilities objectAtIndex:selectedIndexPath.item];
            return;
        }
    }
}

@end
