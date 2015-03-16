//
//  SimpleAlertView.h
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SIAlertView.h>

@interface SimpleAlertView : NSObject

+ (void) showAlertWithTitle: (NSString *) title message: (NSString *) message;
+ (void) showAlertWithTitle: (NSString *) title message: (NSString *) message dismissHandler: (void(^)())dismissHandler;
+ (void) showAlertWithTitle:(NSString *)title message:(NSString *)message destructiveTitle: (NSString *) destructiveTitle destructiveHandler: (void(^)()) destructiveHandler;
+ (void) showAlertWithTitle:(NSString *)title message:(NSString *)message defaultTitle: (NSString *) defaultTitle defaultHandler: (void(^)()) defaultHandler;
@end
