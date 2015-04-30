//
//  Connector.h
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface Connector : NSObject

- (instancetype)initWithSessionId: (NSString *)sessionId;

@property AFURLSessionManager *manager;
@property NSString * sessionId;

- (void) requestSessionId: (void(^)(AFHTTPRequestOperation *operation, NSString * sessionId)) successHandler error: (void(^)(AFHTTPRequestOperation *operation, NSString * message)) errorHandler;

- (void) login: (NSString *)eid password: (NSString * )password success: (void(^)(AFHTTPRequestOperation *operation, NSString * sid)) successHandler error: (void(^)(AFHTTPRequestOperation *operation, id responseObject)) errorHandler;

- (void) requestMyBookings: (NSString *)eid sid: (NSString *)sid success :(void (^)(AFHTTPRequestOperation *, NSArray *))successHandler error:(void (^)(AFHTTPRequestOperation *, id))errorHandler;

- (void) deleteBooking: (NSString *)eid sid: (NSString *)sid password: (NSString *)password bookingId: (NSString *)bookingId success :(void (^)())successHandler error:(void (^)(NSString * message))errorHandler partHandler: (void (^)())partHandler;

- (void) requestDates: (NSString *)eid sid: (NSString *)sid success :(void (^)(NSArray *, NSString *))successHandler error:(void (^)(NSString * message))errorHandler partHandler: (void (^)())partHandler;

- (void) requestFacilities: (NSString *)eid sid: (NSString *)sid date: (NSString *)date userType: (NSString *)userType success :(void (^)(NSArray *))successHandler error:(void (^)(NSString * message))errorHandler;

- (void)requestCourts:(NSString *)eid sid:(NSString *)sid userType:(NSString *)userType date:(NSString *)date facility:(NSString *)facility success:(void (^)(NSDictionary *, NSMutableDictionary *, NSString *))successHandler error:(void (^)(NSString *))errorHandler partHandler:(void (^)())partHandler;

- (void)makeBooking:(NSString *)eid password: (NSString * )password bookParameters: (NSDictionary *)bookParameters bookReferer: (NSString *)bookReferer success:(void (^)(NSString *))successHandler error:(void (^)(NSString *))errorHandler partHandler:(void (^)())partHandler;

@end
