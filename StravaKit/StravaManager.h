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
+ (void)fetchRideWithID:(int)rideID
             completion:(void (^)(StravaRide *ride, NSError* error))completionHandler;

+ (void)fetchRideStreams:(int)rideID
              completion:(void (^)(NSDictionary *streams, NSError *error))completionHandler;

+ (void)fetchRideEfforts:(int)rideID
              completion:(void (^)(NSArray *efforts, NSError *error))completionHandler;



// queue management methods
+ (NSMutableSet*)pendingRequests;
+ (void)cancelAllRequests;


// map helper methods
+ (MKPolyline*)polylineForMapPoints:(NSArray*)latlng;


@end
