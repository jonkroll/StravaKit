//
//  NSDictionary+StravaManager.m
//  StravaClub
//
//  Created by Jon Kroll on 5/28/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import "NSDictionary+StravaManager.h"

@implementation NSDictionary (StravaManager)

- (double)doubleForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj respondsToSelector:@selector(doubleValue)]) {
        return [obj doubleValue];
    } else {
        return 0.0;
    }
}

- (int)intForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj respondsToSelector:@selector(intValue)]) {
        return [obj intValue];
    } else {
        return 0;
    }
}

- (NSDate*)dateForKey:(NSString *)key
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];                  
    return [dateFormatter dateFromString:[self objectForKey:key]];
}

@end