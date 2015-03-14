//
//  SettingsTableTableViewController.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "SettingsTableTableViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "SimpleAlertViewController.h"

@interface SettingsTableTableViewController ()

@end

@implementation SettingsTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView * bgImageView = [[UIImageView alloc] init];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    self.tableView.backgroundView = bgImageView;
    self.tableView.backgroundView.alpha = 0.3;
    self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.clearsSelectionOnViewWillAppear = true;
    
    self.versionNumberLabel.text = [AppDelegate version];
    self.userInfoLabel.text = [User getEID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 1) {
        // log out
        [User clearUser];
        [SIMPLEALERT showAlertWithTitle:@"Goodbye" message:@"Your user info has been cleared." dismissHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:true completion:nil];
            });
        }];
    }
    
    if (indexPath.section == 1 && indexPath.item == 1) {
        // report
        NSString * emailTitle = @"[CityU Sport Facility] Bug Report";
        NSString * version = [AppDelegate version];
        NSString * messageBody = [NSString stringWithFormat:@"Version: %@\nBug description:\n", version];
        NSArray * toRecipents = @[@"Xinhong LIU<app@xinhong.me>"];
        MFMailComposeViewController * mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:false];
        [mc setToRecipients:toRecipents];
        [self presentViewController:mc animated:true completion:nil];
    }
    
    if (indexPath.section == 2 && indexPath.item == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Aahung/cityu-sports"]];
    }
    
    NSIndexPath * selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:true];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
