//
//  StravaRide.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import "StravaRide.h"

@implementation StravaRide

@synthesize id = _id;
@synthesize startDate = _startDate;
@synthesize startDateLocal = _startDateLocal;
@synthesize timeZoneOffset = _timeZoneOffset;
@synthesize elapsedTime = _elapsedTime;
@synthesize movingTime = _movingTime;
@synthesize distanceInMeters = _distanceInMeters;
@synthesize distanceInMiles = _distanceInMiles;
@synthesize averageSpeed = _averageSpeed; 
@synthesize averageWatts = _averageWatts;
@synthesize maximumSpeed = _maximumSpeed;
@synthesize elevationGainInMeters = _elevationGainInMeters;
@synthesize elevationGainInFeet = _elevationGainInFeet;
@synthesize location = _location;
@synthesize name = _name;
@synthesize bike = _bike;
@synthesize athlete = _athlete;
@synthesize description = _description;
@synthesize commute = _commute;
@synthesize trainer = _trainer;

- (id)init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}



@end
