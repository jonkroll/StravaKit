//
//  StravaAthlete.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import "StravaAthlete.h"
#import "NSDictionary+StravaManager.h"

@implementation StravaAthlete

@synthesize id = _id;
@synthesize name = _name;
@synthesize username = _username;

+ (StravaAthlete*)athleteFromDictionary:(NSDictionary*)athleteInfo
{
    StravaAthlete *athlete = [[StravaAthlete alloc] init];
    athlete.id = [athleteInfo intForKey:@"id"];
    athlete.name = [athleteInfo objectForKey:@"name"];
    athlete.username = [athleteInfo objectForKey:@"username"];        
    return athlete;
}

@end
