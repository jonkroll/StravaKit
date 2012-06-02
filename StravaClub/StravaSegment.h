//
//  StravaSegment.h
//  StravaClub
//
//  Created by Jon Kroll on 5/29/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
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

@end
