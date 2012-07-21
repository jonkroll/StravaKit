//
//  StravaRide.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StravaBike.h"
#import "StravaAthlete.h"

@interface StravaRide : NSObject

@property (nonatomic) int id;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *startDateLocal;
@property (nonatomic) NSTimeInterval timeZoneOffset;  // in seconds
@property (nonatomic) NSTimeInterval elapsedTime;  // in seconds
@property (nonatomic) NSTimeInterval movingTime;  // in seconds
@property (nonatomic) double distanceInMeters;
@property (nonatomic) double distanceInMiles;
@property (nonatomic) double averageSpeed;  // in meters per sec
@property (nonatomic) double averageWatts;
@property (nonatomic) double maximumSpeed; // in meters per sec
@property (nonatomic) int elevationGainInMeters;
@property (nonatomic) int elevationGainInFeet;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) StravaBike *bike;
@property (nonatomic, strong) StravaAthlete *athlete;
@property (nonatomic, strong) NSString *description;
@property (nonatomic) BOOL commute;
@property (nonatomic) BOOL trainer;

@end
