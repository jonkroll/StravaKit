//
//  NSDictionary+StravaClient.h
//  StravaClub
//
//  Created by Jon Kroll on 5/28/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (StravaClient)

- (double)doubleForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;
- (NSDate*)dateForKey:(NSString *)key;

@end
