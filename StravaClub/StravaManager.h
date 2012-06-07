//
//  StravaManager.h
//  StravaClub
//
//  Created by Jon Kroll on 5/24/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "StravaRide.h"

@interface StravaManager : NSObject

+ (void)fetchRideWithID:(int)rideID
             completionHandler:(void (^)(StravaRide *ride, NSError* error))handler;

+ (void)fetchRideStreams:(int)rideID
             completion:(void (^)(NSDictionary *streams))completionHandler
                  error:(void (^)(NSError *error))errorHandler;

+ (void)fetchRideEfforts:(int)rideID
              completion:(void (^)(NSArray *efforts))completionHandler
                   error:(void (^)(NSError *error))errorHandler;


// map helper methods
+ (MKPolyline*)polylineForMapPoints:(NSArray*)latlng;

@end
