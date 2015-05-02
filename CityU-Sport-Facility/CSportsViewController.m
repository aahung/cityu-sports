//
//  ProgressViewController.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 30/4/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//


#import "CSportsViewController.h"

@interface CSportsViewController ()

@end

@implementation CSportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tableView != nil) {
        [self initTableViewBackground];
        [self removeExtraTableRows];
        [self initRefreshControl];
    }
}

- (void)initRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)initTableViewBackground {
    // set the background
    UIImageView * bgImageView = [[UIImageView alloc] init];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    self.tableView.backgroundView = bgImageView;
    self.tableView.backgroundView.alpha = 0.15;
    self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)removeExtraTableRows {
    // remove extra rows
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.tableView != nil) {
        NSIndexPath * selectedIndexPath = [self.tableView indexPathForSelectedRow];
        if (selectedIndexPath != nil) {
            [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:true];
        }
    }
}

- (void)showProgressWithTitle: (NSString *)title {
    if (self.hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.removeFromSuperViewOnHide = true;
    }
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = title;
}

- (void)showSuccessProgressWithTitle:(NSString *)title {
    if (self.hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.removeFromSuperViewOnHide = true;
    }
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = [[UIImageView alloc]
                       initWithImage:[UIImage imageNamed:@"checkmark-white"]];
    self.hud.labelText = title;
}

- (void)finishProgress {
    [self.hud hide:YES];
    self.hud = nil;
}

- (void)cancelProgress {
    [self finishProgress];
}

- (void)refresh {
    
}

- (IBAction)unwindToContainerVC:(UIStoryboardSegue *)segue {
    NSLog(@"unwind");
}

@end
