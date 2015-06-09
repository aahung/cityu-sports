//
//  SimpleAlertViewController.h
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 14/3/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SIMPLEALERT [[SimpleAlertViewController alloc] initWithViewController:self]

@interface SimpleAlertViewController : NSObject

- (instancetype)initWithViewController: (UIViewController *) viewController;

- (void)showActionSheetWithTitle: (NSString *)title message: (NSString *)massage destructiveTitle: (NSString *)desTitle destructiveHandler: (void(^)())handler source: (UIView *)source;

- (void) showAlertWithTitle: (NSString *) title message: (NSString *) message;

- (void) showAlertWithTitle: (NSString *) title message: (NSString *) message dismissHandler: (void(^)())dismissHandler;

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message defaultTitle: (NSString *) defaultTitle defaultHandler: (void(^)()) defaultHandler;

@end
