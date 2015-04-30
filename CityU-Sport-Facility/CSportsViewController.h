//
//  ProgressViewController.h
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 30/4/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>

@interface CSportsViewController : UIViewController

@property MBProgressHUD *hud;

- (void) setTableViewBackground: (UITableView *)tableView;
- (void) showProgressWithTitle: (NSString *)title;
- (void) showSuccessProgressWithTitle:(NSString *)title;
- (void) finishProgress;
- (void) cancelProgress;

@end
