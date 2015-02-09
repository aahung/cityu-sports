//
//  Parser.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 7/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import "Parser.h"

@implementation Parser

+ (NSString *)getSessionIdByHTML:(NSString *)html {
    HTMLDocument * document = [HTMLDocument documentWithString:html];
    HTMLElement * node = [document firstNodeMatchingSelector:@"input[name='p_session']"];
    if (node == nil) {
        return nil;
    }
    return [node.attributes valueForKey:@"value"];
}

+ (NSString *)getSIDByHTML:(NSString *)html {
    
    HTMLDocument * document = [HTMLDocument documentWithString:html];
    HTMLElement * userInfoFrame = [document firstNodeMatchingSelector:@"frame[name='main_win']"];
    if (userInfoFrame == nil) {
        return nil;
    }
    NSString * src = [userInfoFrame.attributes valueForKey:@"src"];
    NSArray * userInfoTokens = [src componentsSeparatedByString:@"&"];
    for (NSString * userInfoToken in userInfoTokens) {
        if ([userInfoToken rangeOfString:@"p_user_no"].location != NSNotFound) {
            NSArray * tokens = [userInfoToken componentsSeparatedByString:@"/"];
            if ([tokens count] > 1) {
                return tokens[1];
            }
        }
    }
    return nil;
}

+ (NSArray *) getBookingsByHTML: (NSString *) html {
    NSMutableArray * books = [[NSMutableArray alloc] init];
    
    HTMLDocument * document = [HTMLDocument documentWithString:html];
    NSArray * trs = [document nodesMatchingSelector:@"tr"];
    for (HTMLElement * tr in trs) {
        if ([tr.attributes valueForKey:@"bgcolor"] == nil) {
            continue;
        }
        NSArray * fonts = [tr nodesMatchingSelector:@"font"];
        if ([fonts count] != 4) {
            continue;
        }
        
        NSMutableDictionary * book = [[NSMutableDictionary alloc] init];
        
        // id
        HTMLElement * delA = [tr firstNodeMatchingSelector:@"a"];
        if (delA != nil) {
            NSString * delHref = [delA.attributes valueForKey:@"href"];
            NSArray * tokens = [delHref componentsSeparatedByString:@"/"];
            if ([tokens count] > 1) {
                NSString * id = tokens[0];
                tokens = [id componentsSeparatedByString:@"'"];
                id = tokens[1];
                [book setObject:id forKey:@"id"];
            }
        }
        
        NSArray * smalls;
        HTMLElement * font;
        
        // time
        font = fonts[0];
        smalls = [font nodesMatchingSelector:@"small"];
        if ([smalls count] > 0) {
            NSString * time = @"";
            for (HTMLElement * small in smalls) {
                if (small == smalls[0]) {
                    [book setObject:small.textContent forKey:@"date"];
                } else {
                    time = [time stringByAppendingString:small.textContent];
                }
            }
            [book setObject:time forKey:@"time"];
        }
        
        // facility
        font = fonts[1];
        smalls = [font nodesMatchingSelector:@"small"];
        if ([smalls count] > 0) {
            NSString * string = @"";
            for (HTMLElement * small in smalls) {
                string = [string stringByAppendingString:small.textContent];
                string = [string stringByAppendingString:@" "];
            }
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [book setObject:string forKey:@"facility"];
        }
        
        // venue
        font = fonts[2];
        smalls = [font nodesMatchingSelector:@"small"];
        if ([smalls count] > 0) {
            NSString * string = @"";
            for (HTMLElement * small in smalls) {
                string = [string stringByAppendingString:small.textContent];
            }
            [book setObject:string forKey:@"venue"];
        }
        
        // deadline
        font = fonts[3];
        smalls = [font nodesMatchingSelector:@"small"];
        if ([smalls count] > 0) {
            NSString * string = @"";
            for (HTMLElement * small in smalls) {
                string = [string stringByAppendingString:small.textContent];
            }
            [book setObject:string forKey:@"deadline"];
        }
        
        [books addObject:book];
    }
    return books;
}

+ (NSString *)getConfirmNoByHTML:(NSString *)html {
    HTMLDocument * document = [HTMLDocument documentWithString:html];
    HTMLElement * node = [document firstNodeMatchingSelector:@"input[name='p_sno']"];
    if (node == nil) {
        return nil;
    }
    NSString * confirmNo = [node.attributes valueForKey:@"value"];
    return confirmNo;
}

+ (NSString *)getRequestURLStringByHTML:(NSString *)html {
    NSArray * tokens;
    if ([html rangeOfString:@"opt_left_win"].location != NSNotFound) {
        tokens = [html componentsSeparatedByString:@"\" NAME=\"opt_left_win\""];
    } else {
        tokens = [html componentsSeparatedByString:@"\" NAME=\"body_win\""];
    }
    if ([tokens count] > 0) {
        tokens = [tokens[0] componentsSeparatedByString:@"<FRAME SRC=\""];
        if ([tokens count] > 0) {
            NSString * link = tokens[[tokens count] - 1];
            return [NSString stringWithFormat:@"http://brazil.cityu.edu.hk:8754%@", link];
        }
    }
    return nil;
}

+ (NSString *)getUserTypeByDateURLString:(NSString *)dateURLString {
    NSArray * tokens = [dateURLString componentsSeparatedByString:@"p_user_type_no="];
    if ([tokens count] > 0) {
        NSString * userType = tokens[1];
        tokens = [userType componentsSeparatedByString:@"&"];
        if ([tokens count] > 0) {
            userType = tokens[0];
            return userType;
        }
    }
    return nil;
}

+ (NSArray *)getDatesByHTML:(NSString *)html {
    NSMutableArray * dates = [[NSMutableArray alloc] init];
    
    HTMLDocument * document = [HTMLDocument documentWithString:html];
    NSArray * as = [document nodesMatchingSelector:@"a"];
    for (HTMLElement * a in as) {
        NSString * href = a.attributes[@"href"];
        if (href != nil) {
            NSArray * tokens = [href componentsSeparatedByString:@"date_data('"];
            if ([tokens count] < 1) {
                continue;
            }
            NSString * date = tokens[1];
            tokens = [date componentsSeparatedByString:@"','"];
            if ([tokens count] < 1) {
                continue;
            }
            date = tokens[0];
            [dates addObject:date];
        }
    }
    
    return dates;
}

+ (NSArray *)getFacilitiesByHTML:(NSString *)html {
    NSMutableArray * facilities = [[NSMutableArray alloc] init];
    
    HTMLDocument * document = [HTMLDocument documentWithString:html];
    NSArray * as = [document nodesMatchingSelector:@"a"];
    for (HTMLElement * a in as) {
        NSString * href = a.attributes[@"href"];
        if (href != nil) {
            NSArray * tokens = [href componentsSeparatedByString:@"sub_data('"];
            if ([tokens count] < 1) {
                continue;
            }
            NSString * facility = tokens[1];
            tokens = [facility componentsSeparatedByString:@"'"];
            if ([tokens count] < 1) {
                continue;
            }
            facility = tokens[0];
            [facilities addObject:facility];
        }
    }
    
    return facilities;
}

+ (NSString *)getFacilityNameByCode:(NSString *)code {
    NSDictionary * dict = @{
                            @"BMT": @"Badminton",
                            @"BB": @"Basketball",
                            @"GDR": @"Golf Driving",
                            @"GSIM": @"Golf Simulation",
                            @"ODBB": @"Outdoor Basketball",
                            @"PF": @"Physical Fitness",
                            @"PG 2": @"Practice Gymnasium 2",
                            @"PG 4": @"Practice Gymnasium 4",
                            @"SQ": @"Squash",
                            @"TT": @"Table Tennis",
                            @"VB": @"Volleyball",
                            @"JSFS": @"Handball / 5-on-5 Soccer (Joint Sports Center)",
                            @"JSBV": @"Basketball / Volleyball (Joint Sports Center)",
                            @"JSBF": @"Basketball / Volleyball (Night) (Joint Sports Center)",
                            @"JSGO": @"Golf",
                            @"JSSOA": @"Soccer Pitch (Afternoon) (Joint Sports Center)",
                            @"JSSOF": @"Soccer Pitch (Evening) (Joint Sports Center)",
                            @"JST": @"Tennis (Joint Sports Center)",
                            @"JSTF": @"Tennis (Night) (Joint Sports Center)"
                            };
    if ([dict valueForKey:code] != nil) {
        return [dict valueForKey:code];
    }
    return code;
}

+ (NSString *)getFacilityImageNameByCode:(NSString *)code {
    NSDictionary * dict = @{
                            @"BMT": @"sport_net",
                            @"BB": @"basketball",
                            @"GDR": @"golf",
                            @"GSIM": @"golf",
                            @"ODBB": @"basketball",
                            @"PF": @"weightlift",
                            @"PG 2": @"weightlift",
                            @"PG 4": @"weightlift",
                            @"TT": @"pingpong",
                            @"VB": @"volleyball",
                            @"JSBV": @"basketball",
                            @"JSBF": @"basketball",
                            @"JSGO": @"golf",
                            @"JSSOA": @"football2",
                            @"JSSOF": @"football2",
                            @"JST": @"tennis",
                            @"JSTF": @"tennis"
                            };
    if ([dict valueForKey:code] != nil) {
        return [dict valueForKey:code];
    }
    return @"gorilla";
}

+ (NSDictionary *)getCourtsByHTML:(NSString *)html {
    NSMutableDictionary * courts = [[NSMutableDictionary alloc] init];
    
    HTMLDocument * document = [HTMLDocument documentWithString:html];
    NSArray * as = [document nodesMatchingSelector:@"a"];
    for (HTMLElement * a in as) {
        NSMutableDictionary * court = [[NSMutableDictionary alloc] init];
        
        
        HTMLElement * img = [a firstNodeMatchingSelector:@"img"];
        if (img == nil) {
            // header doesn't have img
            continue;
        }
        
        NSArray * tokens;
        
        if ([img.attributes valueForKey:@"src"] != nil && [[img.attributes valueForKey:@"src"] isEqual: @"/pebook-img/sq_cyan.gif"]) {
            NSString * href = [a.attributes valueForKey:@"href"];
            if ([href rangeOfString:@"alert"].location != NSNotFound) {
                NSString * message;
                tokens = [href componentsSeparatedByString:@"alert('"];
                if ([tokens count] > 1) {
                    message = tokens[1];
                    tokens = [message componentsSeparatedByString:@"'"];
                    if ([tokens count] > 0) {
                        message = tokens[0];
                        [court setObject:message forKey:@"message"];
                    }
                }
            } else {
                tokens = [href componentsSeparatedByString:@"sub_data"];
                if ([tokens count] < 2) {
                    continue;
                }
                NSString * string = tokens[1];
                string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@";" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"'" withString:@""];
                tokens = [string componentsSeparatedByString:@","];
                if ([tokens count] > 4) {
                    [court setObject:tokens[0] forKey:@"date"];
                    [court setObject:tokens[1] forKey:@"court"];
                    [court setObject:tokens[2] forKey:@"venue"];
                    [court setObject:tokens[3] forKey:@"facilityRef"];
                    [court setObject:tokens[4] forKey:@"stime"];
                }
            }
            
            NSString * mouseOver = [a.attributes valueForKey:@"onmouseover"];
            if (mouseOver == nil) {
                continue;
            }
            
            tokens = [mouseOver componentsSeparatedByString:@"/"];
            if ([tokens count] > 0) {
                NSString * readable = tokens[0];
                tokens = [readable componentsSeparatedByString:@"Facility No.: "];
                if ([tokens count] > 1) {
                    readable = tokens[1];
                    [court setObject:readable forKey:@"courtReadable"];
                }
            }
            
            tokens = [mouseOver componentsSeparatedByString:@"Time: $"];
            if ([tokens count] > 1) {
                NSString * readable = tokens[1];
                tokens = [readable componentsSeparatedByString:@"/"];
                if ([tokens count] > 0) {
                    readable = tokens[0];
                    [court setObject:readable forKey:@"timeReadable"];
                }
            }
            
            tokens = [mouseOver componentsSeparatedByString:@"Venue: $/"];
            if ([tokens count] > 1) {
                NSString * readable = tokens[1];
                tokens = [readable componentsSeparatedByString:@"/"];
                if ([tokens count] > 0) {
                    readable = tokens[0];
                    [court setObject:readable forKey:@"venueReadable"];
                }
            }
            
            NSString * key = [court valueForKey:@"timeReadable"];
            if (key != nil) {
                if ([courts valueForKey:key] == nil) {
                    [courts setObject:[[NSMutableArray alloc] init] forKey:key];
                }
                [[courts valueForKey:key] addObject:court];
            }
        }
        
    }
    
    return courts;
}

+ (NSMutableDictionary *)getBookParametersByHTML:(NSString *)html {
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
    HTMLDocument * document = [HTMLDocument documentWithString:html];
    NSArray * inputs = [document nodesMatchingSelector:@"input[type='hidden']"];
    for (HTMLElement * input in inputs) {
        NSString * name = input.attributes[@"name"];
        NSString * value = input.attributes[@"value"];
        NSLog(@"%@: %@", name, value);
        if ([value  isEqual: @""]) {
            // make sure it is @""
            value = @"";
        }
        if (name != nil && value != nil) {
            [parameters setObject:value forKey:name];
        }
    }
    return parameters;
}

+ (NSString *)getMessageByHTML:(NSString *)html {
    
    HTMLDocument * document = [HTMLDocument documentWithString:html];
    NSArray * smalls = [document nodesMatchingSelector:@"small"];
    
    NSString * string = @"";
    
    for (HTMLElement * small in smalls) {
        string = [string stringByAppendingString:small.textContent];
    }
    
    return string;
}

@end
