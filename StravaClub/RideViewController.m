//
//  RideViewController.m
//  StravaClub
//
//  Created by Jon Kroll on 5/23/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import "RideViewController.h"
#import "MBProgressHUD.h"
#import "StravaEffort.h"


@interface RideViewController ()
{
    int _pendingRequests;
}
@end

@implementation RideViewController

@synthesize rideID = _rideID;

@synthesize name = _name;
@synthesize startDate = _startDate;
@synthesize distance = _distance;
@synthesize averageSpeed = _averageSpeed;
@synthesize elevationGain = _elevationGain;
@synthesize location = _location;
@synthesize athleteName = _athleteName;

@synthesize mapView = _mapView;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // set title
    self.navigationItem.title = [NSString stringWithFormat:@"%d", self.rideID];
    
    // show spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // load info
    [StravaClient loadRide:self.rideID delegate:self];
    [StravaClient loadMapRoute:self.rideID delegate:self];  
    [StravaClient loadRideEfforts:self.rideID delegate:self];
    
    _pendingRequests = 2;

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - StravaClient delegate

- (void)rideDidLoad:(StravaRide *)ride {
    
    self.name.text = ride.name;            
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy h:mm a"];          

    
    self.startDate.text = [dateFormatter stringFromDate:ride.startDateLocal];            
    self.distance.text = [NSString stringWithFormat:@"%.1f miles", ride.distanceInMiles];
    self.averageSpeed.text = [NSString stringWithFormat:@"%.1f avg speed", (ride.averageSpeed * 60 * 60 / 1609.344)];  // have to convert meters/sec to mph
    
    self.elevationGain.text = [NSString stringWithFormat:@"%d ft elevation gain", ride.elevationGainInFeet];
    self.location.text = ride.location;       
    self.athleteName.text = ride.athlete.name;   
    
    _pendingRequests--;
    if (_pendingRequests <= 0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
}

- (void)rideID:(int)rideID mapRouteDidLoad:(MKPolyline*)polyline boundingBox:(MKMapRect)boundingBox {

    _pendingRequests--;

    self.routeLine = polyline;
    
    [self.mapView addOverlay:self.routeLine];    
    [self.mapView setVisibleMapRect:boundingBox];
    [self.mapView setHidden:NO];
    
    _pendingRequests--;
    if (_pendingRequests <= 0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
}

- (void)rideID:(int)rideID rideEffortsDidLoad:(NSArray*)efforts
{
    
    NSLog(@"%d efforts found for this ride", [efforts count]);
    
    for (StravaEffort *effort in efforts) {
        
        NSLog(@"%@",effort.segment.name);
        
    }
    
    
}


#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKOverlayView *overlayView = nil;
    
    if (overlay == self.routeLine)
    {
        if (nil == self.routeLineView)
        {
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
            self.routeLineView.fillColor = [UIColor redColor];
            self.routeLineView.strokeColor = [UIColor redColor];
            self.routeLineView.lineWidth = 3;
        }
        
        overlayView = self.routeLineView;
    }
    
    return overlayView;
}


@end
