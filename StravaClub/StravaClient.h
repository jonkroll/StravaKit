//
//  StravaClient.h
//  StravaClub
//
//  Created by Jon Kroll on 5/24/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "StravaRide.h"

@protocol StravaClientDelegate <NSObject>
@optional

- (void)rideDidLoad:(StravaRide*)ride;
- (void)rideID:(int)rideID mapRouteDidLoad:(MKPolyline*)polyline boundingBox:(MKMapRect)boundingBox;
- (void)rideID:(int)rideID rideEffortsDidLoad:(NSArray*)efforts;

- (void)didFailWithError:(NSError*)error errorInfo:(NSDictionary*)errorInfo;

@end


@interface StravaClient : NSObject

+ (void)loadRide:(int)rideID delegate:(id<StravaClientDelegate>)delegate;
+ (void)loadMapRoute:(int)rideID delegate:(id<StravaClientDelegate>)delegate;
+ (void)loadRideEfforts:(int)rideID delegate:(id<StravaClientDelegate>)delegate;

@end
