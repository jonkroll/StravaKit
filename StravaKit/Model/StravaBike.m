//
//  StravaBike.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import "StravaBike.h"
#import "NSDictionary+StravaManager.h"

@implementation StravaBike

@synthesize id = _id;
@synthesize name = _name;
@synthesize defaultBike = _defaultBike;
@synthesize weight = _weight;
@synthesize frameType = _frameType;
@synthesize notes = _notes;
@synthesize retired = _retired;
@synthesize athleteId = _athleteId;

+ (StravaBike*)bikeFromDictionary:(NSDictionary*)bikeInfo
{
    StravaBike *bike = [[StravaBike alloc] init];
    
    bike.id = [bikeInfo intForKey:@"id"];
    bike.name = [bikeInfo objectForKey:@"name"];
    bike.defaultBike = [[bikeInfo objectForKey:@"defaultBike"] boolValue];
    bike.weight = [bikeInfo doubleForKey:@"weight"];
    bike.frameType = [bikeInfo intForKey:@"frameType"];
    bike.notes = [bikeInfo objectForKey:@"notes"];
    bike.retired = [[bikeInfo objectForKey:@"retired"] boolValue];
    bike.athleteId = [bikeInfo intForKey:@"athleteId"];
    
    return bike;
}

@end
