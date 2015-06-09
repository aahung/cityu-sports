//
//  SimpleAlertViewController.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 14/3/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "SimpleAlertViewController.h"
#import "SimpleAlertView.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IOS7 SYSTEM_VERSION_LESS_THAN(@"8.0")

@interface SimpleAlertViewController()

    // reference of the target view controller
    @property (weak) UIViewController *_viewController;

@end

@implementation SimpleAlertViewController

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self._viewController = viewController;
    }
    return self;
}

- (void) showAlertWithTitle: (NSString *) title message: (NSString *) message {
    [self showAlertWithTitle:title message:message dismissHandler:nil];
}

- (void) showAlertWithTitle: (NSString *) title message: (NSString *) message dismissHandler: (void(^)())dismissHandler {
    if (IOS7) {
        [SimpleAlertView showAlertWithTitle:title message:message dismissHandler:dismissHandler];
        return;
    }
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (dismissHandler != nil)
            dismissHandler();
    }];
    
    [alertController addAction:defaultAction];
    
    [self._viewController presentViewController:alertController animated:true completion:nil];
}

- (void)showActionSheetWithTitle: (NSString *)title message: (NSString *)message destructiveTitle: (NSString *)desTitle destructiveHandler: (void(^)())handler source: (UIView *)source{
    if (IOS7) {
        [SimpleAlertView showAlertWithTitle:title message:message destructiveTitle:desTitle destructiveHandler:handler];
        return;
    }
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * destructiveAction = [UIAlertAction actionWithTitle:desTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        handler();
    }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:destructiveAction];
    [alertController addAction:cancelAction];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = source;
        popover.sourceRect = source.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self._viewController presentViewController:alertController animated:true completion:nil];
}

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message defaultTitle: (NSString *) defaultTitle defaultHandler: (void(^)()) defaultHandler {
    if (IOS7) {
        [SimpleAlertView showAlertWithTitle:title message:message defaultTitle:defaultTitle defaultHandler:defaultHandler];
        return;
    }
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *defaultAction = [UIAlertAction
                               actionWithTitle:defaultTitle
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   if (defaultHandler != nil)
                                       defaultHandler();
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:defaultAction];
    
    [self._viewController presentViewController:alertController animated:true completion:nil];
}


@end
