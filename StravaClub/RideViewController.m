//
//  RideViewController.m
//  StravaClub
//
//  Created by Jon Kroll on 5/23/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import "RideViewController.h"
#import "SegmentViewController.h"
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

@synthesize chartWebView = _chartWebView;

@synthesize efforts = _efforts;
@synthesize effortsTable = _effortsTable;

@synthesize pageControl = _pageControl;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.rideID > 0) {
        [self loadRideDetails:self.rideID];
    }
    
}

- (void)loadRideDetails:(int)rideID
{
    self.rideID = rideID;

    if (IDIOM == IPAD) {

        [self.mapView setHidden:YES];
        [self.chartWebView setHidden:YES];
        [self.chartWebView loadHTMLString:@"" baseURL:nil];
        [self.effortsTable setHidden:YES];
        
    }
        
    if (IDIOM == IPHONE) {
    
        // scrollView width = 960 (320 * 3 = three sliding content panels)
        self.scrollView.contentSize = CGSizeMake(960, self.scrollView.frame.size.height);
        
        
        // (1) set up map view
        
        self.mapView = [[MKMapView alloc] init];
        self.mapView.frame = CGRectMake(0, 0, 320, 160);
        self.mapView.scrollEnabled = NO;
        self.mapView.zoomEnabled = NO;
        self.mapView.delegate = self;
        [self.mapView setHidden:YES];  // hide map until points load
        [self.scrollView addSubview:self.mapView];

        // add empty view on top of the mapView so it can respond to touch event
        UIButton *mapButton = [[UIButton alloc] initWithFrame:self.mapView.frame];
        [self.scrollView addSubview:mapButton];
        [self.scrollView bringSubviewToFront:mapButton];
        //[mapButton addTarget:self action:@selector(mapViewClicked:) forControlEvents:UIControlEventTouchUpInside];

        
        // (2) set up elevation chart
        
        self.chartWebView = [[UIWebView alloc] initWithFrame:CGRectMake(320, 0, 320, 160)];
        self.chartWebView.userInteractionEnabled=NO;
        [self.scrollView addSubview:self.chartWebView];
       
        
        // (3) set up eforts table
        
        self.effortsTable = [[UITableView alloc] init];
        self.effortsTable.frame = CGRectMake(640, 0, 320, 160);
        self.effortsTable.delegate = self;
        self.effortsTable.dataSource = self;

        [self.scrollView addSubview:self.effortsTable];

    }

    // show spinner
    
    if (![MBProgressHUD HUDForView:self.view]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    // load info    
    [StravaManager fetchRideWithID:rideID
                        completionHandler:(^(StravaRide *ride, NSError *error) {

            if (error) {
                // handle error somehow
            }

            if (rideID == self.rideID) {  // could be different if user has navigated to a different ride while we waited for response
     
                // set title
                self.navigationItem.title = ride.name;
            
                [self showRideDetails:ride];
                [self decrementPendingRequests];
            }
        
        })];
    
    [StravaManager fetchRideStreams:rideID
                        completion:(^(NSDictionary *streams) {

            if (rideID == self.rideID) { 
                MKPolyline *polyline = [StravaManager polylineForMapPoints:[streams objectForKey:@"latlng"]];
            
                [self.mapView removeOverlays:[self.mapView overlays]];
            
                self.routeLine = polyline;
                [self.mapView addOverlay:self.routeLine];    
                [self.mapView setVisibleMapRect:polyline.boundingMapRect];
                [self.mapView setHidden:NO];
                
                [self.chartWebView loadHTMLString:[self buildAltitudeChartHTMLFromStreams:streams] baseURL:nil];
                [self.chartWebView setHidden:NO];
                
            
                [self decrementPendingRequests];
            }
        })
                             error:nil   
     ];    
    
    [StravaManager fetchRideEfforts:rideID
                         completion:(^(NSArray *efforts) {
                       
            if (rideID == self.rideID) { 
                self.efforts = efforts;
                [self.effortsTable reloadData];
                [self decrementPendingRequests];
                [self.effortsTable setHidden:NO];
            }
        })
                              error:nil   
     ];
    
    _pendingRequests = 3;

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (IDIOM == IPAD) {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);        
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }   
}

- (void)decrementPendingRequests
{
    _pendingRequests--;
    
    if (_pendingRequests <= 0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (IDIOM == IPHONE) {
            // set up page control
            
            self.pageControl = [[DDPageControl alloc] init];    
            self.pageControl.center = CGPointMake(160,240);
            self.pageControl.numberOfPages = 3;
            self.pageControl.currentPage = 0;
            
            [self.pageControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];
            [self.pageControl setType: DDPageControlTypeOnFullOffEmpty];
            [self.pageControl setOnColor:[UIColor lightGrayColor]];
            [self.pageControl setOffColor:[UIColor lightGrayColor]];
            [self.pageControl setIndicatorDiameter: 10.0f];
            [self.pageControl setIndicatorSpace: 10.0f];
            
            
            [self.view addSubview:self.pageControl];
        }
    }    
}

- (void)showRideDetails:(StravaRide *)ride {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy h:mm a"];          
    
    self.name.text          = ride.name;            
    self.location.text      = ride.location;       
    self.athleteName.text   = ride.athlete.name;       
    self.startDate.text     = [dateFormatter stringFromDate:ride.startDateLocal];            
    self.distance.text      = [NSString stringWithFormat:@"%.1f miles", ride.distanceInMiles];
    self.averageSpeed.text  = [NSString stringWithFormat:@"%.1f avg speed", (ride.averageSpeed * 60 * 60 / 1609.344)];  // have to convert meters/sec to mph    
    self.elevationGain.text = [NSString stringWithFormat:@"%d ft elevation gain", ride.elevationGainInFeet];
}


#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKOverlayView *overlayView = nil;
    
    if (overlay == self.routeLine)
    {
        if (nil == self.routeLineView || self.routeLineView.overlay != overlay)
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
        
        [self.navigationController pushViewController:vc animated:NO];
    }  
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.efforts.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? @"Segments on this Ride" : @"";
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
        
        [self performSegueWithIdentifier:@"ShowSegment" sender:self];
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


#pragma mark

- (NSString*)buildAltitudeChartHTMLFromStreams:(NSDictionary*)streams
{    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:streams options:0 error:&err];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    
    NSMutableString *html = [[NSMutableString alloc] init];
    
    [html appendString:@"<script>"];
    
    NSString *filePath;

    filePath = [[NSBundle mainBundle] pathForResource:@"raphael-min" ofType:@"js"];  
    if (filePath) {  
        [html appendString:[NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&err]];  
    }  
    filePath = [[NSBundle mainBundle] pathForResource:@"g.raphael-min" ofType:@"js"];  
    if (filePath) {  
        [html appendString:[NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&err]];  
    }  
    filePath = [[NSBundle mainBundle] pathForResource:@"g.line-min" ofType:@"js"];  
    if (filePath) {  
        [html appendString:[NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&err]];  
    }  

    [html appendString:@"</script>"];
        
    int chartHeight, chartWidth;
    if (IDIOM == IPAD) {
        chartWidth=640;
        chartHeight=160;

    } else {
        chartWidth=280;        
        chartHeight=120;
    }
    
    [html appendString:[NSString stringWithFormat:@"<script>var jdata=%@; var chartWidth=%d; var chartHeight=%d;</script>", jsonString, chartWidth, chartHeight]]; 

    filePath = [[NSBundle mainBundle] pathForResource:@"chart" ofType:@"html"];  
    if (filePath) {  
        [html appendString:[NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&err]];  
    }  

    return html;
    
}

@end
