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

- (void)tryLogin {
    [self showProgressWithTitle:@"Requesting session..."];
        
    Connector * connector = [[Connector alloc] init];
    [connector requestSessionId:^(AFHTTPRequestOperation *operation, NSString *sessionId) {
        NSLog(@"session id: %@", sessionId);
        [User setSessionId:sessionId];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self showProgressWithTitle:@"Trying to log in..."];
        }];
        [connector login:[self eid] password:[self password] success:^(AFHTTPRequestOperation *operation, NSString *sid) {
            [User setSID:sid];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self showSuccessProgressWithTitle:@"Success"];
                [self finishProgress];
                [self performSegueWithIdentifier:@"in" sender:self];
            }];
        } error:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self cancelProgress];
                [SIMPLEALERT showAlertWithTitle:@"Log in failed" message:@"Fails to get your SID, maybe your EID or password is wrong."];
            }];
        }];
    } error:^(AFHTTPRequestOperation *operation, NSString * message) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self cancelProgress];
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

- (NSString *)eid {
    return self.eidTextField.text;
}

- (NSString *)password {
    return self.passwordTextField.text;
}

- (BOOL)validateTextField {
    return !([[self eid]  isEqual: @""] || [[self password]  isEqual: @""]);
}

- (void)hideKeyboard {
    [self.eidTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)didEndEditing:(id)sender {
    [User setEID:[self eid] password:[self password]];
}
@end
