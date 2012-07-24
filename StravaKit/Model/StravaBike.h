//
//  StravaBike.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StravaBike : NSObject

@property (nonatomic) int id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL defaultBike;
@property (nonatomic) double weight;
@property (nonatomic) int frameType;  // 1=mtn, 2=cross, 3=road, 4=tt
@property (nonatomic, strong) NSString *notes;
@property (nonatomic) BOOL retired;

@property (nonatomic) int athleteId;

// parse NSDictionary for bike attributes and return a new StravaBike object
+ (StravaBike*)bikeFromDictionary:(NSDictionary*)bikeInfo;

@end
