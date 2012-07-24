//
//  StravaRide.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import "StravaRide.h"
#import "NSDictionary+StravaManager.h"

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


+ (StravaRide*)rideFromDictionary:(NSDictionary*)rideInfo
{
    StravaRide *ride = [[StravaRide alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];                  
    
    // fill object    
    
    ride.id = [rideInfo intForKey:@"id"];
    ride.startDate = [rideInfo dateForKey:@"startDate"];
    ride.startDateLocal = [rideInfo dateForKey:@"startDateLocal"];
    ride.timeZoneOffset = [rideInfo intForKey:@"timeZoneOffset"];
    ride.elapsedTime = [rideInfo intForKey:@"elapsedTime"];
    ride.movingTime = [rideInfo intForKey:@"movingTime"];
    ride.distanceInMeters = [rideInfo doubleForKey:@"distance"];
    ride.distanceInMiles = [rideInfo doubleForKey:@"distance"]/ 1609.344;
    ride.averageSpeed = [rideInfo doubleForKey:@"averageSpeed"];
    ride.averageWatts = [rideInfo doubleForKey:@"averageWatts"];
    ride.maximumSpeed = [rideInfo doubleForKey:@"maximumSpeed"];                
    ride.elevationGainInMeters = [rideInfo intForKey:@"elevationGain"];
    ride.elevationGainInFeet = [rideInfo intForKey:@"elevationGain"] / 0.3048;
    ride.location = [rideInfo objectForKey:@"location"];
    ride.name = [rideInfo objectForKey:@"name"];
    
    NSDictionary* bikeInfo = [rideInfo objectForKey:@"bike"]; 
    if (bikeInfo) {
        ride.bike = [StravaBike bikeFromDictionary:bikeInfo];
    }
    
    NSDictionary* athleteInfo = [rideInfo objectForKey:@"athlete"];   
    if (athleteInfo) {       
        ride.athlete = [StravaAthlete athleteFromDictionary:athleteInfo];
    }
    
    ride.description = [rideInfo objectForKey:@"description"];
    ride.commute = [[rideInfo objectForKey:@"commute"] boolValue];
    ride.trainer = [[rideInfo objectForKey:@"trainer"] boolValue];
    
    return ride;
}

@end