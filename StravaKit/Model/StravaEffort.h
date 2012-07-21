//
//  StravaEffort.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StravaSegment.h"

@interface StravaEffort : NSObject

@property (nonatomic) int id;
@property (nonatomic, strong) NSDate *startDateLocal;
@property (nonatomic) int elapsedTime; // in seconds
@property (nonatomic) int movingTime; // in seconds
@property (nonatomic) double distance;
@property (nonatomic) double averageSpeed;

@property (nonatomic, strong) StravaSegment* segment;

@end
