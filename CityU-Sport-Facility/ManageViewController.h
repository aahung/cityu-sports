//
//  ManageViewController.h
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface ManageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property NSArray * books;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIRefreshControl *refreshControl;
- (IBAction)editAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end
