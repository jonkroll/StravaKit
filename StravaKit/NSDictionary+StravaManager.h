//
//  NSDictionary+StravaManager.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (StravaManager)

- (double)doubleForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;
- (NSDate*)dateForKey:(NSString *)key;

@end
