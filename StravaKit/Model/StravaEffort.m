//
//  StravaEffort.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import "StravaEffort.h"
#import "NSDictionary+StravaManager.h"

@implementation StravaEffort

@synthesize id = _id;
@synthesize startDateLocal = _startDateLocal;
@synthesize elapsedTime = _elapsedTime;
@synthesize movingTime = _movingTime;
@synthesize distance = _distance;
@synthesize averageSpeed = _averageSpeed;

@synthesize segment = _segment;

+ (StravaEffort*)effortFromDictionary:(NSDictionary *)effortInfo
{
    NSDictionary *effortDict = [effortInfo objectForKey:@"effort"];             
    StravaEffort *effort = [[StravaEffort alloc] init];
    
    effort.id = [effortDict intForKey:@"id"];
    effort.startDateLocal = [effortDict dateForKey:@"start_date_local"];
    effort.elapsedTime = [effortDict intForKey:@"elapsed_time"];
    effort.movingTime = [effortDict intForKey:@"moving_time"];
    effort.distance = [effortDict doubleForKey:@"distance"];
    effort.averageSpeed = [effortDict doubleForKey:@"average_speed"];
    
    effort.segment = [StravaSegment segmentFromDictionary:[effortInfo objectForKey:@"segment"]];
    
    return effort;
}

@end
