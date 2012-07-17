//
//  RideViewController.h
//  StravaClub
//
//  Created by Jon Kroll on 5/23/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import "StravaManager.h"
#import "DDPageControl.h"

@interface RideViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) int rideID;

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *athleteName;
@property (nonatomic, strong) IBOutlet UILabel *startDate;
@property (nonatomic, strong) IBOutlet UILabel *distance;
@property (nonatomic, strong) IBOutlet UILabel *movingTime;
@property (nonatomic, strong) IBOutlet UILabel *averageSpeed;
@property (nonatomic, strong) IBOutlet UILabel *elevationGain;
@property (nonatomic, strong) IBOutlet UILabel *location;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIWebView *chartWebView;
@property (nonatomic, strong) IBOutlet UIButton *mapButton;

@property (nonatomic, strong) MKPolyline *routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;

@property (nonatomic, strong) NSArray *efforts;
@property (nonatomic, strong) IBOutlet UITableView *effortsTable;

@property (nonatomic, strong) IBOutlet DDPageControl *pageControl;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, strong) UIActionSheet *popoverActionsheet;

- (void)loadRideDetails:(int)rideID;

- (IBAction)barButtonItemAction:(id)sender;

@end
