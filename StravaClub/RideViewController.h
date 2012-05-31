//
//  RideViewController.h
//  StravaClub
//
//  Created by Jon Kroll on 5/23/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "StravaClient.h"

@interface RideViewController : UIViewController <StravaClientDelegate, MKMapViewDelegate>

@property (nonatomic) int rideID;

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *startDate;
@property (nonatomic, strong) IBOutlet UILabel *distance;
@property (nonatomic, strong) IBOutlet UILabel *averageSpeed;
@property (nonatomic, strong) IBOutlet UILabel *elevationGain;
@property (nonatomic, strong) IBOutlet UILabel *location;
@property (nonatomic, strong) IBOutlet UILabel *athleteName;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) MKPolyline *routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;

@end
