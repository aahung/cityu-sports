//
//  SelectDateViewController.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "SelectDateViewController.h"
#import <MBProgressHUD.h>
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
    
    UIImageView * bgImageView = [[UIImageView alloc] init];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    self.tableView.backgroundView = bgImageView;
    self.tableView.backgroundView.alpha = 0.3;
    self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"pull to refresh"];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.dates = @[];
    
    [self refresh];
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

- (void) refresh {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = true;
    hud.labelText = @"Request date URL";
    Connector * connector = [[Connector alloc] initWithSessionId:[User getSessionId]];
    [connector requestDates:[User getEID] sid:[User getSID] success:^(NSArray * dates, NSString * userType) {
        [User setUserType:userType];
        self.dates = dates;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [hud hide:true];
            [self.tableView reloadData];
        });
    } error:^(NSString * message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            hud.labelText = @"Error";
            [hud hide:true afterDelay:1.0];
            [SIMPLEALERT showAlertWithTitle:@"Error" message:message];
        });
    } partHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.labelText = @"Request date list";
        });
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"facility"]) {
        UINavigationController * navigationController = (UINavigationController *)[segue destinationViewController];
        SelectFacilityViewController * viewController;
        if ([navigationController isKindOfClass:[SelectFacilityViewController class]]) {
            viewController = (SelectFacilityViewController *)navigationController;
        } else {
            viewController = (SelectFacilityViewController *)[navigationController topViewController];
        }
        if (viewController != nil) {
            NSIndexPath * selectedIndexPath = [self.tableView indexPathForSelectedRow];
            viewController.date = [self.dates objectAtIndex:selectedIndexPath.item];
            return;
        }
    }
}

@end
