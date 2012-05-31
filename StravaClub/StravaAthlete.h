//
//  StravaAthlete.h
//  StravaClub
//
//  Created by Jon Kroll on 5/24/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StravaAthlete : NSObject

@property (nonatomic) int id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *username;

@end
