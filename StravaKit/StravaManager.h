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


// the following parameters can be passed in the NSDictionary object:
//     clubId, athleteId, athleteName, startDate, endDate, startId
+ (void)fetchRideListWithParameters:(NSDictionary*)parameters
                         completion:(void (^)(NSArray *rides, NSError* error))completionHandler
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


// TODO: add methods for rest of API data access
//    https://stravasite-main.pbworks.com/w/page/51754105/Strava%20API%20Overview


// request management methods
+ (NSMutableSet*)pendingRequests;
+ (void)cancelAllRequests;


// map helper methods
+ (MKPolyline*)polylineForMapPoints:(NSArray*)latlng;


@end
