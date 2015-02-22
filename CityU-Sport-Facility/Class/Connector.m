//
//  Connector.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "Connector.h"
#import "Parser.h"

@implementation Connector

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSHTTPCookieStorage * cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        configuration.HTTPCookieStorage = cookieStorage;
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return self;
}

- (instancetype)initWithSessionId: (NSString *)sessionId
{
    self = [super init];
    if (self) {
        self = [self init];
        self.sessionId = sessionId;
    }
    return self;
}

- (void) requestSessionId: (void(^)(AFHTTPRequestOperation *operation, NSString * sessionId)) successHandler error: (void(^)(AFHTTPRequestOperation *operation, NSString * message)) errorHandler {
    
    NSDictionary * parameters = @{};
    
    [self makePOSTRequestWithURL:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_logon.show" referer:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_first.show" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString * sessionId = [Parser getSessionIdByHTML:html];
        if (sessionId == nil) {
            NSString * errorMessage = [Parser getMessageByHTML:html];
            if ([errorMessage isEqual: @""]) {
                errorMessage = @"Booking system is not open during 00:00 - 08:00 HKT or on public holiday";
            }
            errorHandler(nil, errorMessage);
        } else {
            self.sessionId = sessionId;
            successHandler(operation, sessionId);
        }
    } error:^(AFHTTPRequestOperation *operation, id responseObject) {
        errorHandler(operation, @"Booking system is not open during 00:00 - 08:00 HKT or on public holiday");
    }];
}

- (void)login: (NSString *)eid password:(NSString *) password success :(void (^)(AFHTTPRequestOperation *, NSString *))successHandler error:(void (^)(AFHTTPRequestOperation *, id))errorHandler {
    
    NSDictionary * parameters = @{@"p_status_code": @"",
                                  @"p_sno": @"",
                                  @"p_session": self.sessionId,
                                  @"p_username": eid,
                                  @"p_password": password
                                  };
    
    [self makePOSTRequestWithURL:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_logon.show" referer:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_logon.show" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString * sid = [Parser getSIDByHTML:html];
        if (sid == nil) {
            errorHandler(nil, nil);
        } else {
            successHandler(operation, sid);
        }
    } error:errorHandler];
}

- (void) requestMyBookings: (NSString *)eid sid: (NSString *)sid success :(void (^)(AFHTTPRequestOperation *, NSArray *))successHandler error:(void (^)(AFHTTPRequestOperation *, id))errorHandler {
    
    NSDictionary * parameters = @{
                                  @"p_session": self.sessionId,
                                  @"p_username": eid,
                                  @"p_user_no": sid
                                  };
    [self makePOSTRequestWithURL:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_enqbook.show" referer:[NSString stringWithFormat:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_main.toc?p_session=%@&p_username=%@&p_user_no=/%@/", self.sessionId, eid, sid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSArray * books = [Parser getBookingsByHTML:html];
        if (books == nil) {
            errorHandler(nil, nil);
        } else {
            successHandler(operation, books);
        }
    } error:errorHandler];
    
}

- (void)deleteBooking:(NSString *)eid sid:(NSString *)sid password: (NSString *)password bookingId:(NSString *)bookingId success:(void (^)())successHandler error:(void (^)())errorHandler partHandler: (void (^)())partHandler{
    
    NSDictionary * parameters = @{
                                  @"p_session": self.sessionId,
                                  @"p_username": eid,
                                  @"p_user_no": sid,
                                  @"p_choice": [NSString stringWithFormat:@"%@/", bookingId],
                                  @"p_enq": @"Y"
                                   };
    
    [self makePOSTRequestWithURL:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_conf_msg_del.show" referer:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_enqbook.show" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString * confirmNo = [Parser getConfirmNoByHTML:html];
        if (confirmNo == nil) {
            errorHandler();
            return;
        }
        partHandler();
        // second step
        NSDictionary * parameters = @{
                       @"p_username": eid,
                       @"p_password": password,
                       @"p_sno": confirmNo
                       };
        [self makePOSTRequestWithURL:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_conf_msg_del.show" referer:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_conf_msg_del.show" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            successHandler();
        } error:^(AFHTTPRequestOperation *operation, id responseObject) {
            errorHandler();
        }];
    } error: ^(AFHTTPRequestOperation *operation, id responseObject) {
        errorHandler();
    }];
}

- (void) makePOSTRequestWithURL: (NSString *) URLString referer: (NSString *) referer parameters: (NSDictionary *) parameters success: (void(^)(AFHTTPRequestOperation *operation, id responseObject)) successHandler error: (void(^)(AFHTTPRequestOperation *operation, id responseObject)) errorHandler{
    
    
    [self makeRequestWithURL:URLString method:@"POST" referer:referer parameters:parameters success:successHandler error:errorHandler];
    
    
}

- (void) makeGETRequestWithURL: (NSString *) URLString referer: (NSString *) referer parameters: (NSDictionary *) parameters success: (void(^)(AFHTTPRequestOperation *operation, id responseObject)) successHandler error: (void(^)(AFHTTPRequestOperation *operation, id responseObject)) errorHandler{
    
    
    [self makeRequestWithURL:URLString method:@"GET" referer:referer parameters:parameters success:successHandler error:errorHandler];
    
    
}

- (void) makeRequestWithURL: (NSString *) URLString method: (NSString *)method referer: (NSString *) referer parameters: (NSDictionary *) parameters success: (void(^)(AFHTTPRequestOperation *operation, id responseObject)) successHandler error: (void(^)(AFHTTPRequestOperation *operation, id responseObject)) errorHandler{
    
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:URLString parameters:parameters error:nil];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [request setValue:[Connector userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setValue:referer forHTTPHeaderField:@"Referer"];
    [op setCompletionBlockWithSuccess:successHandler failure:errorHandler];
    [[NSOperationQueue mainQueue] addOperation:op];
    
    
}

- (void)requestDates:(NSString *)eid sid:(NSString *)sid success:(void (^)(NSArray *, NSString *))successHandler error:(void (^)(NSString * message))errorHandler partHandler: (void (^)())partHandler{
    
    NSDictionary * parameters = @{
                                  @"p_session": self.sessionId,
                                  @"p_username": eid,
                                  @"p_user_no": sid
                                  };
    [self makePOSTRequestWithURL:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_book.show" referer:[NSString stringWithFormat:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_main.toc?p_session=%@&p_username=%@&p_user_no=/%@/", self.sessionId, eid, sid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString * requestDateURLString = [Parser getRequestURLStringByHTML:html];
        if (requestDateURLString == nil) {
            errorHandler(@"Fail to get dates URL");
            return;
        }
        NSString * userType = [Parser getUserTypeByDateURLString:requestDateURLString];
        if (userType == nil) {
            errorHandler(@"Fail to get user type");
            return;
        }
        
        partHandler();
        [self requestDates2:eid sid:sid requestDateURLString:requestDateURLString userType: userType success:successHandler error:errorHandler];
        
    } error:^(AFHTTPRequestOperation *operation, id responseObject) {
        errorHandler(@"Fail to get dates URL");
    }];
}

- (void)requestDates2:(NSString *)eid sid:(NSString *)sid requestDateURLString: (NSString *)requestDateURLString userType: (NSString *)userType success:(void (^)(NSArray *, NSString *))successHandler error:(void (^)(NSString * message))errorHandler{
    
    [self makeGETRequestWithURL:requestDateURLString referer:[NSString stringWithFormat:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_book.show?p_session=%@&p_username=%@&p_user_no=/%@/", self.sessionId, eid, sid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSArray * dates = [Parser getDatesByHTML:html];
        successHandler(dates, userType);
        
    } error:^(AFHTTPRequestOperation *operation, id responseObject) {
        errorHandler(@"Fails to get dates");
    }];
}

- (void)requestFacilities:(NSString *)eid sid:(NSString *)sid date:(NSString *)date userType: (NSString *)userType success:(void (^)(NSArray *))successHandler error:(void (^)(NSString *))errorHandler {
    
    NSDictionary * parameters = @{
                                  @"p_session": self.sessionId,
                                  @"p_username": eid,
                                  @"p_user_no": sid,
                                  @"p_user_type_no": userType,
                                  @"p_alter_adv_ref": @"",
                                  @"p_alter_book_no": @"",
                                  @"p_enq": @"",
                                  @"p_date": date,
                                  @"p_empty": @""
                                  };
    [self makePOSTRequestWithURL:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_opt_fac_types.show" referer:[NSString stringWithFormat:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_calendar.show?p_session=%@&p_username=%@&p_user_no=/%@/", self.sessionId, eid, sid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSArray * facilities = [Parser getFacilitiesByHTML:html];
        if (facilities == nil) {
            errorHandler(@"Fail to get facilities");
        } else {
            successHandler(facilities);
        }
    } error:^(AFHTTPRequestOperation *operation, id responseObject) {
        errorHandler(@"Fail to get facilities");
    }];
}

- (void)requestCourts:(NSString *)eid sid:(NSString *)sid userType:(NSString *)userType date:(NSString *)date facility:(NSString *)facility success:(void (^)(NSDictionary *, NSMutableDictionary *, NSString *))successHandler error:(void (^)(NSString *))errorHandler partHandler:(void (^)())partHandler {
    NSDictionary * parameters = @{
                                  @"p_session": self.sessionId,
                                  @"p_username": eid,
                                  @"p_user_no": sid,
                                  @"p_user_type_no": userType,
                                  @"p_alter_adv_ref": @"",
                                  @"p_alter_book_no": @"",
                                  @"p_enq": @"",
                                  @"p_date": date,
                                  @"p_choice": facility
                                  };
    [self makePOSTRequestWithURL:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_book_conf.show" referer:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_opt_fac_types.show" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString * requestCourtURLString = [Parser getRequestURLStringByHTML:html];
        if (requestCourtURLString == nil) {
            errorHandler(@"Fail to get court URL");
            return;
        }
        
        partHandler();
        [self requestCourts2:requestCourtURLString success:successHandler error:errorHandler];
        
    } error:^(AFHTTPRequestOperation *operation, id responseObject) {
        errorHandler(@"Fail to get court URL");
    }];
}

- (void)requestCourts2:(NSString *)requestCourtURLString success:(void (^)(NSDictionary *, NSMutableDictionary *, NSString *))successHandler error:(void (^)(NSString * message))errorHandler{
    
    [self makeGETRequestWithURL:requestCourtURLString referer:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_book_conf.show" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary * courts = [Parser getCourtsByHTML:html];
        successHandler(courts, [Parser getBookParametersByHTML:html], requestCourtURLString);
        
    } error:^(AFHTTPRequestOperation *operation, id responseObject) {
        errorHandler(@"Fails to get dates");
    }];
}

- (void)makeBooking:(NSString *)eid password:(NSString *)password bookParameters:(NSDictionary *)bookParameters bookReferer:(NSString *)bookReferer success:(void (^)(NSString *))successHandler error:(void (^)(NSString *))errorHandler partHandler:(void (^)())partHandler {
    [self makePOSTRequestWithURL:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_conf_msg.show" referer:bookReferer parameters:bookParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString * confirmNo = [Parser getConfirmNoByHTML:html];
        if (confirmNo == nil) {
            errorHandler(@"Fail to get confirmation number");
            return;
        }
        
        partHandler();
        
        [self makeBooking2:eid password:password confirmNo:confirmNo success:successHandler error:errorHandler];
        
    } error:^(AFHTTPRequestOperation *operation, id responseObject) {
        errorHandler(@"Fail to make request");
    }];
}

- (void)makeBooking2:(NSString *)eid password:(NSString *)password confirmNo: (NSString *)confirmNo success:(void (^)(NSString *))successHandler error:(void (^)(NSString *))errorHandler {
    
    NSDictionary * parameters = @{
                                  @"p_password": password,
                                  @"p_username": eid,
                                  @"p_sno": confirmNo
                                  };
    [self makePOSTRequestWithURL:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_conf_msg.show" referer:@"http://brazil.cityu.edu.hk:8754/fbi/owa/fbi_web_conf_msg.show" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString * html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        successHandler([Parser getMessageByHTML:html]);
        
    } error:^(AFHTTPRequestOperation *operation, id responseObject) {
        errorHandler(@"Fail to make confirmation");
    }];
}

+ (NSString *)userAgent {
    return @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36";
}

@end
