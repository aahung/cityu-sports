//
//  SelectDateViewController.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "SelectDateViewController.h"
#import "SimpleAlertViewController.h"
#import "Connector.h"
#import "User.h"
#import "SelectFacilityViewController.h"
#import "Parser.h"


@interface SelectDateViewController ()

@end

@implementation SelectDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dates = @[];
    
    [self mockPullDown];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dates count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"date"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"date"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyyMMdd0000";
    NSDate * date = [dateFormatter dateFromString:self.dates[indexPath.item]];
    if (date == nil) {
        cell.textLabel.text = @"parsing error";
        cell.detailTextLabel.text = @"";
        cell.userInteractionEnabled = false;
    } else {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        cell.textLabel.text = [dateFormatter stringFromDate:date];
        dateFormatter.dateFormat = @"EEEE";
        cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        dateFormatter.dateFormat = @"e";
        [cell.imageView setImage:[UIImage imageNamed:[Parser getWeekdayImageNameByIndex:[[dateFormatter stringFromDate:date] integerValue] - 1]]];
        cell.userInteractionEnabled = true;
    }
    
    return cell;
}

- (void)refresh {
    [self showProgressWithTitle:@"Requesting date URL..."];
    Connector * connector = [[Connector alloc] initWithSessionId:[User getSessionId]];
    [connector requestDates:[User getEID] sid:[User getSID] success:^(NSArray * dates, NSString * userType) {
        [User setUserType:userType];
        self.dates = dates;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
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
            [self showProgressWithTitle:@"Requesting date list..."];
        }];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"facility"]) {
        SelectFacilityViewController * viewController = (SelectFacilityViewController *)[segue destinationViewController];
        if (viewController != nil) {
            NSIndexPath * selectedIndexPath = [self.tableView indexPathForSelectedRow];
            viewController.date = [self.dates objectAtIndex:selectedIndexPath.item];
            return;
        }
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (viewController == self.navigationController) {
        [self mockPullDown];
    }
}

@end
