//
//  RideViewController.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RideViewController.h"
#import "StravaEffort.h"
#import "MapAnnotation.h"
#import "MKMapView+StravaManager.h"

#define MAP_INSETS UIEdgeInsetsMake(40.0, 40.0, 40.0, 40.0)

@interface RideViewController ()
{
    CGRect _originalMapFrame;
}
@end

@implementation RideViewController

@synthesize rideID = _rideID;

@synthesize name = _name;
@synthesize athleteName = _athleteName;
@synthesize startDate = _startDate;
@synthesize distance = _distance;
@synthesize movingTime = _movingTime;
@synthesize averageSpeed = _averageSpeed;
@synthesize elevationGain = _elevationGain;
@synthesize location = _location;
@synthesize scrollView = _scrollView;
@synthesize mapButton = _mapButton;
@synthesize mapView = _mapView;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;
@synthesize chartWebView = _chartWebView;
@synthesize efforts = _efforts;
@synthesize effortsTable = _effortsTable;
@synthesize pageControl = _pageControl;
@synthesize actionButton = _actionButton;
@synthesize popoverActionsheet = _popoverActionsheet;

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

    // cancel any previous requests
    [StravaManager cancelAllRequests];
    
        
    if (IDIOM == IPHONE) {
    
        int numScrollPanels = 2;
        self.scrollView.contentSize = CGSizeMake(320 * numScrollPanels, 
                                                 self.scrollView.frame.size.height);
        
        // (1) set up map view
        
        self.mapView = [[MKMapView alloc] init];
        self.mapView.frame = CGRectMake(0, 0, 320, 160);
        self.mapView.scrollEnabled = NO;
        self.mapView.zoomEnabled = NO;
        self.mapView.delegate = self;
        [self.mapView setHidden:YES];  // hide map until points load
        [self.scrollView addSubview:self.mapView];

        // add empty view on top of the mapView so it can respond to touch event
        self.mapButton = [[UIButton alloc] initWithFrame:self.mapView.frame];
        [self.scrollView addSubview:self.mapButton];
        [self.scrollView bringSubviewToFront:self.mapButton];
        [self.mapButton addTarget:self action:@selector(expandMapView:) forControlEvents:UIControlEventTouchUpInside];

        
        // (2) set up elevation chart
        
        self.chartWebView = [[UIWebView alloc] initWithFrame:CGRectMake(320, 0, 320, 160)];
        self.chartWebView.userInteractionEnabled=NO;
        [self.scrollView addSubview:self.chartWebView];
               
        // (3) set up eforts table
        
//        self.effortsTable = [[UITableView alloc] init];
//        self.effortsTable.frame = CGRectMake(640, 0, 320, 160);
//        self.effortsTable.delegate = self;
//        self.effortsTable.dataSource = self;
//
//        [self.scrollView addSubview:self.effortsTable];

        // show spinner - TODO
//        if (![MBProgressHUD HUDForView:self.view]) {
//            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        }
        
    } 
    
    if (IDIOM == IPAD) {
        
        if (!CGRectEqualToRect(self.mapView.frame, self.view.frame)) {
            // do not hide mapView during load if it is already full screen
            [self.mapView setHidden:YES];
        }
        [self.chartWebView setHidden:YES];
        [self.chartWebView loadHTMLString:@"" baseURL:nil];
        
        self.chartWebView.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.chartWebView.layer.borderWidth = 2.0;
      
        
        [self.effortsTable setHidden:YES];
        

        // add empty view on top of the mapView so it can respond to touch event        
        self.mapButton = [[UIButton alloc] initWithFrame:self.mapView.frame];
        [self.view addSubview:self.mapButton];
        [self.view bringSubviewToFront:self.mapButton];
        [self.mapButton addTarget:self action:@selector(expandMapView:) forControlEvents:UIControlEventTouchUpInside];
    }


    // load ride info    
    [StravaManager fetchRideWithID:rideID
                        completion:(^(StravaRide *ride, NSError *error) {

            if (error) {
                // handle error somehow
            } else {
                self.navigationItem.title = ride.name;            
                [self showRideDetails:ride];
                self.actionButton.enabled = YES;                
            }
        
            [self hideSpinnerIfDone];
        
        })];
    
    
    [StravaManager fetchRideStreams:rideID
                        completion:(^(NSDictionary *streams, NSError *error) {

            if (error) {
                // handle error somehow
            } else {

                MKPolyline *polyline = [StravaManager polylineForMapPoints:[streams objectForKey:@"latlng"]];
            
                [self.mapView removeOverlays:[self.mapView overlays]];
                [self.mapView removeAnnotations:[self.mapView annotations]];
            
                self.routeLine = polyline;
                [self.mapView addOverlay:self.routeLine];    
                
                
                NSArray *firstPoint = (NSArray*)[[streams objectForKey:@"latlng"] objectAtIndex:0];
                NSArray *lastPoint  = (NSArray*)[[streams objectForKey:@"latlng"] lastObject];
                
                
                CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(
                                                [[firstPoint objectAtIndex:0] doubleValue], 
                                                [[firstPoint objectAtIndex:1] doubleValue]);
                
                MapAnnotation *startAnnotation = [[MapAnnotation alloc] initWithCoordinate:startCoordinate
                                                                                   withTag:0
                                                                                 withTitle:nil 
                                                                              withSubtitle:nil];

                
                
                CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake(
                                                [[lastPoint objectAtIndex:0] doubleValue], 
                                                [[lastPoint objectAtIndex:1] doubleValue]);

                
                MapAnnotation *endAnnotation = [[MapAnnotation alloc] initWithCoordinate:endCoordinate
                                                                                   withTag:1
                                                                                 withTitle:nil 
                                                                              withSubtitle:nil];

                
                NSArray *annotations = [NSArray arrayWithObjects:startAnnotation, endAnnotation, nil];
                
                
                [self.mapView addAnnotations:annotations];
                
                [self.mapView setVisibleMapRectForAllOverlaysWithPadding:MAP_INSETS];

                [self.mapView setHidden:NO];
                
                
                [self.chartWebView loadHTMLString:[self buildElevationChartHTMLFromStreams:streams] baseURL:nil];
                [self.chartWebView setHidden:NO];
                
            }
        
            [self hideSpinnerIfDone];
        }) 
    ];
    
/*
 [StravaManager fetchRideEfforts:rideID
                         completion:(^(NSArray *efforts, NSError *error) {
                      
            if (error) {
                // handle error somehow
            }
        
            self.efforts = efforts;
            [self.effortsTable reloadData];
            [self.effortsTable setHidden:NO];

        })   
     ];
*/
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (IDIOM == IPAD) {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);        
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }   
}

- (void)hideSpinnerIfDone
{
    if ([[StravaManager pendingRequests] count] == 0) {
        //        [MBProgressHUD hideHUDForView:self.view animated:YES];  // TODO
        
        if (IDIOM == IPHONE && !self.pageControl) {
            [self showPageControl];
        }
    }
}

- (void)showPageControl
{
    self.pageControl = [[DDPageControl alloc] init];    
    self.pageControl.center = CGPointMake(160,240);
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
                
    [self.pageControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];
    [self.pageControl setType: DDPageControlTypeOnFullOffEmpty];
    [self.pageControl setOnColor:[UIColor lightGrayColor]];
    [self.pageControl setOffColor:[UIColor lightGrayColor]];
    [self.pageControl setIndicatorDiameter: 10.0f];
    [self.pageControl setIndicatorSpace: 10.0f];
    
    [self.view addSubview:self.pageControl];    
}


- (void)showRideDetails:(StravaRide *)ride {

    // make labels visible
    for (UIView *view in self.view.subviews) {
        if ([view isMemberOfClass:[UILabel class]]) {
            view.hidden = NO;
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"h:mm a"];          
    NSString *activityTime = [dateFormatter stringFromDate:ride.startDateLocal];

    [dateFormatter setDateFormat:@"EEEE MMMM dd, yyyy "];          
    NSString *activityDate = [dateFormatter stringFromDate:ride.startDateLocal];
    
    NSTimeInterval movingTime = ride.movingTime;
    
    int hours = floor(movingTime / (60 * 60));
    int minutes = floor((movingTime - (hours * 60 * 60)) / 60);
    int seconds = trunc(movingTime - (minutes * 60) - (hours * 60 * 60));
    
    NSString *movingTimeText;
    if (hours > 0) {
        movingTimeText = [NSString stringWithFormat:@"%d:%d:%d", hours, minutes, seconds];
    } else {
        movingTimeText = [NSString stringWithFormat:@"%d:%d", minutes, seconds];
    }
    
    
    self.name.text          = ride.name;
    self.athleteName.text   = [NSString stringWithFormat:@"Ridden by %@", ride.athlete.name];
    self.location.text      = [NSString stringWithFormat:@"Near %@", ride.location];       
    
    self.startDate.text     = [NSString stringWithFormat:@"%@ on %@", activityTime, activityDate];         
    if (IDIOM == IPAD) {
        // add athlete name on the same line as the date in the ipad version
        self.startDate.text = [NSString stringWithFormat:@"Ridden by %@ at %@", ride.athlete.name, self.startDate.text]; 
    } 
    
    self.distance.text      = [NSString stringWithFormat:@"%.1f miles", ride.distanceInMiles];
    self.movingTime.text    = movingTimeText;
    self.averageSpeed.text  = [NSString stringWithFormat:@"%.1f", (ride.averageSpeed * 60 * 60 / 1609.344)];  // have to convert meters/sec to mph    
    self.elevationGain.text = [NSString stringWithFormat:@"%d feet", ride.elevationGainInFeet];
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
     
- (MKAnnotationView *) mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKPinAnnotationView *annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation 
                                                                   reuseIdentifier:@"Pin"];
    if ([annotation isMemberOfClass:[MapAnnotation class]]) {
        switch ([(MapAnnotation*)annotation tag]) {
            case 0:
                annView.pinColor = MKPinAnnotationColorGreen;  // start pin
                break;
            case 1:    
                annView.pinColor = MKPinAnnotationColorRed;  // end pin
                break;
        }
    }
    
    annView.animatesDrop = NO;
    annView.canShowCallout = NO;
    return annView;
}

- (void)expandMapView:(id)sender
{
    if (IDIOM == IPAD) {

        [self.view bringSubviewToFront:self.mapView];

        _originalMapFrame = self.mapView.frame;
        
        // expand map to cover entire view controller        
        [UIView animateWithDuration:0.2
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.mapView.frame = self.view.frame;
                         }
                         completion:^(BOOL finished){

                             UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(collapseMapView:)];
                             [self.navigationItem setLeftBarButtonItem:doneButton];
                         }];
        
    } else {
        
        UIViewController *vc = [[UIViewController alloc] init];
        
        [self.navigationController pushViewController:vc animated:NO];
    }  
}

- (void)collapseMapView:(id)sender
{
    // collpase map to original size        
    
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.mapView.frame = _originalMapFrame;
                     }
                     completion:^(BOOL finished){
                         
                         [self.mapView setVisibleMapRectForAllOverlaysWithPadding:MAP_INSETS];                         
                         [self.view sendSubviewToBack:self.mapView];                
                         [self.navigationItem setLeftBarButtonItem:nil];

                     }];
}


#pragma mark - TableView

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
//    if (IDIOM == IPAD) {
//
//    } else {
//        [self performSegueWithIdentifier:@"ShowSegment" sender:self];
//    }
}


#pragma mark - DDPageControl triggered actions

- (void)pageControlClicked:(id)sender
{
	DDPageControl *thePageControl = (DDPageControl *)sender ;
	
	// we need to scroll to the new index
	[self.scrollView setContentOffset: CGPointMake(self.scrollView.bounds.size.width * thePageControl.currentPage, self.scrollView.contentOffset.y) animated: YES] ;
}


#pragma mark - UIScrollView delegate methods

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

- (NSString*)buildElevationChartHTMLFromStreams:(NSDictionary*)streams
{   
    NSMutableString *html = [[NSMutableString alloc] init];

    if (streams) {
        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:streams options:0 error:&err];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
        
        int chartHeight, chartWidth;
        if (IDIOM == IPAD) {
            chartWidth  = 640;
            chartHeight = 160;
            
        } else {
            chartWidth  = 280;        
            chartHeight = 120;
        }
        
        NSArray *jsFileIncludes = [NSArray arrayWithObjects:@"raphael-min",@"g.raphael-min",@"g.line-min",nil];
        
        [html appendString:@"<script>"];
        for (NSString *jsFilename in jsFileIncludes) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:jsFilename ofType:@"js"];  
            if (filePath) {  
                [html appendString:[NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&err]];  
            } else {
                NSLog(@"ERROR: missing javascript include file %@.js", jsFilename);
            }
        }
        [html appendString:@"</script>"];
        
        [html appendString:[NSString stringWithFormat:@"<script>var jdata=%@; var chartWidth=%d; var chartHeight=%d;</script>", jsonString, chartWidth, chartHeight]]; 

        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"chart" ofType:@"html"];  
        if (filePath) {  
            [html appendString:[NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&err]]; 
        } else {
            NSLog(@"ERROR: missing html file %@", @"chart.html");
        }  
    }

    return html;
}

#pragma mark - UIActionSheet delegate

- (IBAction) barButtonItemAction:(id)sender
{
    if (self.rideID) {    
        
        // If the actionsheet is visible it is dismissed, if it not visible a new one is created
        if ([self.popoverActionsheet isVisible]) {
            [self.popoverActionsheet dismissWithClickedButtonIndex:[self.popoverActionsheet cancelButtonIndex] animated:YES];
        } else {
            
            self.popoverActionsheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                                  delegate:self 
                                                         cancelButtonTitle:@"Cancel" 
                                                    destructiveButtonTitle:nil 
                                                         otherButtonTitles:nil];
            
            [self.popoverActionsheet addButtonWithTitle:@"Email Link to This Ride"];
            [self.popoverActionsheet addButtonWithTitle:@"Open in Safari"];
            
            // show "Open in Chrome" button if user has Chrome browser app installed
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome:"]]) {
                [self.popoverActionsheet addButtonWithTitle:@"Open in Chrome"];
            }
            
            [self.popoverActionsheet showFromBarButtonItem:sender animated:YES];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    
    NSURL *rideURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://app.strava.com/rides/%d", self.rideID]];
    
    switch (buttonIndex) {
        case 1: {
            // email link to ride
            if ([MFMailComposeViewController canSendMail]) {
                [self showEmailModalView];
            }
            break;
        }
        case 2: {
            // open in Safari
            [[UIApplication sharedApplication] openURL:rideURL];
            break;
        }
        case 3: {
            // open in Chrome
            
            NSString *scheme = rideURL.scheme;

            NSString *chromeScheme = nil;
            if ([scheme isEqualToString:@"http"]) {
                chromeScheme = @"googlechrome";
            } else if ([scheme isEqualToString:@"https"]) {
                chromeScheme = @"googlechromes";
            }
            
            // Proceed only if a valid Google Chrome URI Scheme is available.
            if (chromeScheme) {
                NSString *absoluteString = [rideURL absoluteString];
                NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
                NSString *urlNoScheme = [absoluteString substringFromIndex:rangeForScheme.location];
                NSString *chromeURLString = [chromeScheme stringByAppendingString:urlNoScheme];
                NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
                
                // Open the URL with Chrome.
                [[UIApplication sharedApplication] openURL:chromeURL];
            }
            
            break;
        }
    }
}

#pragma mark - MFMailComposeViewController delegate

- (IBAction)showEmailModalView
{
    MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
    mcvc.mailComposeDelegate = self;
    //mcvc.navigationBar.tintColor = ;
    
    [mcvc setSubject:[NSString stringWithFormat:@"Strava Ride: %@", self.name.text]];
     
     NSString *messageBody = [NSString stringWithFormat: @"\n\n\n<p>Check out this ride I found on Strava:</p><p><a href='http://app.strava.com/rides/%d'>%@</a></p>", self.rideID, self.name.text];
    [mcvc setMessageBody:messageBody isHTML:YES];
    
    [self.navigationController presentModalViewController:mcvc animated:YES];
}


// Dismisses the email composition interface when users tap Cancel or Send. 
// Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error
{ 
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;            
        default:
        {
            UIAlertView *alert = 
            [[UIAlertView alloc] initWithTitle:@"Email" 
                                       message:@"Sending Failed - Unknown Error"
                                      delegate:self 
                             cancelButtonTitle:@"OK" 
                             otherButtonTitles: nil];
            [alert show];
        }    
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
