//
//  StravaAthlete.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StravaAthlete : NSObject

@property (nonatomic) int id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *username;

// parse NSDictionary for athlete attributes and return a new StravaAthlete object
+ (StravaAthlete*)athleteFromDictionary:(NSDictionary*)athleteInfo;

@end
