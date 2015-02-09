//
//  SimpleAlertView.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "SimpleAlertView.h"

@implementation SimpleAlertView

+ (void) showAlertWithTitle: (NSString *) title message: (NSString *) message {
    [SimpleAlertView showAlertWithTitle:title message:message dismissHandler:nil];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message dismissHandler:(void (^)())dismissHandler {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              if (dismissHandler != nil) {
                                  dismissHandler();
                              }
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}


+ (void) showAlertWithTitle:(NSString *)title message:(NSString *)message destructiveTitle: (NSString *) destructiveTitle destructiveHandler: (void(^)(SIAlertView * alert)) destructiveHandler {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeDefault
                          handler:nil];
    [alertView addButtonWithTitle:destructiveTitle
                             type:SIAlertViewButtonTypeDestructive
                          handler:destructiveHandler];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

+ (void) showAlertWithTitle:(NSString *)title message:(NSString *)message defaultTitle: (NSString *) defaultTitle defaultHandler: (void(^)(SIAlertView * alert)) defaultHandler {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeCancel
                          handler:nil];
    [alertView addButtonWithTitle:defaultTitle
                             type:SIAlertViewButtonTypeDefault
                          handler:defaultHandler];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

@end
