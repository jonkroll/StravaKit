//
//  StravaSegment.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import "StravaSegment.h"
#import "NSDictionary+StravaManager.h"

@implementation StravaSegment

@synthesize id = _id;
@synthesize name = _name;
@synthesize distance = _distance;
@synthesize elevationGain = _elevationGain;
@synthesize elevationHigh = _elevationHigh;
@synthesize elevationLow = _elevationLow;
@synthesize averageGrade = _averageGrade;
@synthesize climbCategory = _climbCategory;
@synthesize startLatLong = _startLatLong;
@synthesize endLatLong = _endLatLong;
@synthesize elevationDifference = _elevationDifference;

+ (StravaSegment*)segmentFromDictionary:(NSDictionary *)segmentInfo
{
    StravaSegment *segment = [[StravaSegment alloc] init];
    
    segment.id = [segmentInfo intForKey:@"id"];
    segment.name = [segmentInfo objectForKey:@"name"];
    segment.climbCategory = [segmentInfo intForKey:@"climb_category"];
    segment.averageGrade = [segmentInfo doubleForKey:@"average_grade"];
    segment.elevationDifference = [segmentInfo doubleForKey:@"elev_difference"];
    
    NSArray *startLoc = [segmentInfo objectForKey:@"start_latlng"];
    NSArray *endLoc = [segmentInfo objectForKey:@"end_latlng"];
    
    segment.startLatLong = CLLocationCoordinate2DMake([[startLoc objectAtIndex:0] doubleValue],
                                                      [[startLoc objectAtIndex:1] doubleValue]);
    segment.endLatLong = CLLocationCoordinate2DMake([[endLoc objectAtIndex:0] doubleValue],
                                                    [[endLoc objectAtIndex:1] doubleValue]);
    return segment;
}

@end
