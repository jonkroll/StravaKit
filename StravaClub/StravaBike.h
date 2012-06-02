//
//  StravaBike.h
//  StravaClub
//
//  Created by Jon Kroll on 5/24/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
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

@end
