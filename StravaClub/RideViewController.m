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

@synthesize scrollView = _scrollView;

@synthesize mapView = _mapView;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;

@synthesize efforts = _efforts;
@synthesize effortsTable = _effortsTable;

@synthesize pageControl = _pageControl;


- (void)viewDidLoad
{
    [super viewDidLoad];

    // set title
    self.navigationItem.title = [NSString stringWithFormat:@"%d", self.rideID];
    
    // ???
    self.scrollView.contentSize = CGSizeMake(960, self.scrollView.frame.size.height);
    
    self.mapView = [[MKMapView alloc] init];
    self.mapView.frame = CGRectMake(0, 0, 320, 160);
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.delegate = self;

    [self.scrollView addSubview:self.mapView];

    // add empty view on top of the mapView so it can respond to touch event
    UIButton *mapButton = [[UIButton alloc] initWithFrame:self.mapView.frame];
    [self.scrollView addSubview:mapButton];
    [self.scrollView bringSubviewToFront:mapButton];
    [mapButton addTarget:self action:@selector(mapViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.effortsTable = [[UITableView alloc] init];
    self.effortsTable.frame = CGRectMake(320, 0, 320, 160);
    self.effortsTable.delegate = self;
    self.effortsTable.dataSource = self;

    [self.scrollView addSubview:self.effortsTable];

    
    self.pageControl = [[DDPageControl alloc] init];    
    self.pageControl.center = CGPointMake(160,240);
    
    [self.pageControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];

    [self.pageControl setType: DDPageControlTypeOnFullOffEmpty];
    [self.pageControl setOnColor: [UIColor lightGrayColor]];
    [self.pageControl setOffColor: [UIColor lightGrayColor]];
    [self.pageControl setIndicatorDiameter: 10.0f];
    [self.pageControl setIndicatorSpace: 10.0f];
    
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;

    [self.view addSubview:self.pageControl];
    
    // show spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // load info
    [StravaClient loadRide:self.rideID delegate:self];
    [StravaClient loadMapRoute:self.rideID delegate:self];  
    [StravaClient loadRideEfforts:self.rideID delegate:self];
    
    _pendingRequests = 3;

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

    self.routeLine = polyline;
    
    [self.mapView addOverlay:self.routeLine];    
    [self.mapView setVisibleMapRect:boundingBox];
    //[self.mapView setHidden:NO];
    
    
    _pendingRequests--;
    if (_pendingRequests <= 0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)rideID:(int)rideID rideEffortsDidLoad:(NSArray*)efforts
{
    //NSLog(@"%d efforts found for this ride", [efforts count]);
    
    self.efforts = efforts;
    
    // reload table
    [self.effortsTable reloadData];
    
    _pendingRequests--;
    if (_pendingRequests <= 0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
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

- (void)mapViewClicked:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
    } else {
        
        UIViewController *vc = [[UIViewController alloc] init];
        
        [self.navigationController pushViewController:vc animated:YES];
    }  
}


#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.efforts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        
    }
    
    
    StravaEffort *effort = [self.efforts objectAtIndex:indexPath.row];
    cell.textLabel.text = effort.segment.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
    } else {
        
        UIViewController *vc = [[UIViewController alloc] init];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - DDPageControl triggered actions

- (void)pageControlClicked:(id)sender
{
	DDPageControl *thePageControl = (DDPageControl *)sender ;
	
	// we need to scroll to the new index
	[self.scrollView setContentOffset: CGPointMake(self.scrollView.bounds.size.width * thePageControl.currentPage, self.scrollView.contentOffset.y) animated: YES] ;
}


#pragma mark UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat pageWidth = scrollView.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
	NSInteger nearestNumber = lround(fractionalPage) ;
	
	if (self.pageControl.currentPage != nearestNumber)
	{
		self.pageControl.currentPage = nearestNumber ;
		
		// if we are dragging, we want to update the page control directly during the drag
		if (scrollView.dragging)
			[self.pageControl updateCurrentPageDisplay] ;
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
	// if we are animating (triggered by clicking on the page control), we update the page control
	[self.pageControl updateCurrentPageDisplay] ;
}

@end
