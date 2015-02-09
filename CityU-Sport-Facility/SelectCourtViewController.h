//
//  SelectTimeViewController.h
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCourtViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIRefreshControl * refreshControl;
@property NSString * date;
@property NSString * facility;
@property NSArray * times;
@property NSDictionary * courts;
@property NSMutableDictionary * bookParameters;
@property NSString * bookReferer;

@end
