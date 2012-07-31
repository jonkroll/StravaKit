//
//  StravaManager.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "StravaAthlete.h"
#import "StravaBike.h"
#import "StravaClub.h"
#import "StravaEffort.h"
#import "StravaRide.h"
#import "StravaSegment.h"

@interface StravaManager : NSObject


// data request methods

+ (void)fetchRideListWithCompletion:(void (^)(NSArray *rides, NSError* error))completionHandler
                         useCache:(BOOL)useCache;

+ (void)fetchRideWithID:(int)rideID
             completion:(void (^)(StravaRide *ride, NSError* error))completionHandler;

+ (void)fetchRideEfforts:(int)rideID
              completion:(void (^)(NSArray *efforts, NSError *error))completionHandler;

// the following stream type names can be passed in the array:
//     altitude, distance, grade_smooth, latlng, moving, outlier, resting
//     temp, time, total_elevation, velocity_smooth, watts_calc
+ (void)fetchRideStreams:(int)rideID
              forStreams:(NSArray*)streams
              completion:(void (^)(NSDictionary *streams, NSError *error))completionHandler;


// request management methods
+ (NSMutableSet*)pendingRequests;
+ (void)cancelAllRequests;


// map helper methods
+ (MKPolyline*)polylineForMapPoints:(NSArray*)latlng;


@end
