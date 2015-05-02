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
#import "CSportsViewController.h"

@interface ManageViewController : CSportsViewController<UITableViewDataSource, UITableViewDelegate, EKEventViewDelegate>

@property NSArray *books;

@property UILabel *emptyLabel;

@end
