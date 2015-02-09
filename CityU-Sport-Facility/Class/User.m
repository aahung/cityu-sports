//
//  User.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "User.h"

@implementation User

+ (void) setEID: (NSString *) eid password: (NSString *) password {
    [[NSUserDefaults standardUserDefaults] setObject:eid forKey:@"eid"];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) getEID {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"eid"];
}

+ (NSString *) getPassword {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
}

+ (void) setSID: (NSString *) sid {
    [[NSUserDefaults standardUserDefaults] setObject:sid forKey:@"sid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) setUserType: (NSString *) userType {
    [[NSUserDefaults standardUserDefaults] setObject:userType forKey:@"usertype"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) setSessionId: (NSString *) sessionId {
    [[NSUserDefaults standardUserDefaults] setObject:sessionId forKey:@"sessionid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) getSID {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"sid"];
}
+ (NSString *) getUserType {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"usertype"];
}
+ (NSString *) getSessionId {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"sessionid"];
}

+ (void) clearUser {
    for (NSString * key in @[@"sid", @"eid", @"password", @"sessionid", @"usertype"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
