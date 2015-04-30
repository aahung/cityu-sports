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
}

- (void) setTableViewBackground:(UITableView *)tableView {
    // set the background
    UIImageView * bgImageView = [[UIImageView alloc] init];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    tableView.backgroundView = bgImageView;
    tableView.backgroundView.alpha = 0.15;
    tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showProgressWithTitle: (NSString *)title {
    if (_hud == nil) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.removeFromSuperViewOnHide = true;
    }
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = title;
}

- (void) showSuccessProgressWithTitle:(NSString *)title {
    if (_hud == nil || _hud.alpha < 1.0) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.removeFromSuperViewOnHide = true;
    }
    _hud.mode = MBProgressHUDModeCustomView;
    _hud.customView = [[UIImageView alloc]
                       initWithImage:[UIImage imageNamed:@"checkmark-white"]];
    _hud.labelText = title;
}

- (void) finishProgress {
    [_hud hide:YES];
    _hud = nil;
}

- (void) cancelProgress {
    [self finishProgress];
}

@end
