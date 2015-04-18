//
//  ViewController.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "ViewController.h"
#import "SimpleAlertViewController.h"
#import "User.h"
#import "Connector.h"
#import <MBProgressHUD.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // tapping background hide keyboard
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [singleTap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:singleTap];
    [self.navigationController.view addGestureRecognizer:singleTap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.eidTextField.text = [User getEID];
    self.passwordTextField.text = [User getPassword];
    
    if ([self validateTextField]) {
        [self tryLogin];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tryLogin {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = true;
    hud.labelText = @"Request session";
        
    Connector * connector = [[Connector alloc] init];
    [connector requestSessionId:^(AFHTTPRequestOperation *operation, NSString *sessionId) {
        NSLog(@"session id: %@", sessionId);
        [User setSessionId:sessionId];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            hud.labelText = @"Log in";
        }];
        [connector login:[self eid] password:[self password] success:^(AFHTTPRequestOperation *operation, NSString *sid) {
            [User setSID:sid];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                hud.mode = MBProgressHUDModeCustomView;
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
                hud.labelText = @"Success";
                [hud hide:true afterDelay:0.5];
                [self performSegueWithIdentifier:@"in" sender:self];
            }];
        } error:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                hud.labelText = @"Error";
                [hud hide:true afterDelay:1.0];
                [SIMPLEALERT showAlertWithTitle:@"Log in failed" message:@"Fails to get your SID, maybe your EID or password is wrong."];
            }];
        }];
    } error:^(AFHTTPRequestOperation *operation, NSString * message) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            hud.labelText = @"Error";
            [hud hide:true afterDelay:1.0];
            [SIMPLEALERT showAlertWithTitle:@"Failed to get session" message:message];
        }];
    }];
}

- (IBAction)loginAction:(id)sender {
    if ([self validateTextField]) {
        [self tryLogin];
    } else {
        [SIMPLEALERT showAlertWithTitle:@"Error" message:@"Please input your EID and password"];
        return;
    }
}

- (NSString *) eid {
    return self.eidTextField.text;
}

- (NSString *) password {
    return self.passwordTextField.text;
}

- (BOOL) validateTextField {
    return !([[self eid]  isEqual: @""] || [[self password]  isEqual: @""]);
}

- (void) hideKeyboard {
    [self.eidTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)didEndEditing:(id)sender {
    [User setEID:[self eid] password:[self password]];
}
@end
