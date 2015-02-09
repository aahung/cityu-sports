//
//  Parser.h
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HTMLReader.h>

@interface Parser : NSObject

+ (NSString *) getSessionIdByHTML: (NSString *) html;

+ (NSString *) getSIDByHTML: (NSString *) html;

+ (NSArray *) getBookingsByHTML: (NSString *) html;

+ (NSString *) getConfirmNoByHTML: (NSString *) html;

+ (NSString *) getRequestURLStringByHTML: (NSString *) html;
+ (NSString *) getUserTypeByDateURLString: (NSString *) dateURLString;

+ (NSArray *) getDatesByHTML: (NSString *) html;

+ (NSArray *) getFacilitiesByHTML: (NSString *) html;
+ (NSString *) getFacilityNameByCode: (NSString *) code;
+ (NSString *) getFacilityImageNameByCode: (NSString *) code;

+ (NSDictionary *) getCourtsByHTML: (NSString *) html;
+ (NSMutableDictionary *) getBookParametersByHTML: (NSString *) html;

+ (NSString *) getMessageByHTML: (NSString *) html;
@end
