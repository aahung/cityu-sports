//
//  User.h
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

+ (void) setEID: (NSString *) eid password: (NSString *) password;
+ (void) setSID: (NSString *) sid;
+ (void) setUserType: (NSString *) userType;
+ (void) setSessionId: (NSString *) sessionId;
+ (NSString *) getEID;
+ (NSString *) getPassword;
+ (NSString *) getSID;
+ (NSString *) getUserType;
+ (NSString *) getSessionId;
+ (void) clearUser;

@end
