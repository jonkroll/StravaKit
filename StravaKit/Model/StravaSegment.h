//
//  StravaSegment.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface StravaSegment : NSObject

@property (nonatomic) int id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) double distance;
@property (nonatomic) double elevationGain;
@property (nonatomic) double elevationHigh;
@property (nonatomic) double elevationLow;
@property (nonatomic) double averageGrade;
@property (nonatomic) int climbCategory;
@property (nonatomic) CLLocationCoordinate2D startLatLong;
@property (nonatomic) CLLocationCoordinate2D endLatLong;
@property (nonatomic) double elevationDifference;

// parse NSDictionary for segment attributes and return a new StravaSegment object
+ (StravaSegment*)segmentFromDictionary:(NSDictionary*)segmentInfo;

@end
