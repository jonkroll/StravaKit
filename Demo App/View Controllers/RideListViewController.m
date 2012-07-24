//
//  RideListViewController.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import "RideListViewController.h"
#import "RideViewController.h"

@interface RideListViewController ()
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    NSArray *_rides;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation RideListViewController

@synthesize tableView = _tableView;
@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;

@synthesize clubID = _clubID;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // override default text on back button when we go to detail view controller 
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	
    if (_refreshHeaderView == nil) {
        
		EGORefreshTableHeaderView *view = 
        [[EGORefreshTableHeaderView alloc] 
         initWithFrame:CGRectMake(0.0f, 
                                  0.0f - self.tableView.bounds.size.height, 
                                  self.view.frame.size.width, 
                                  self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
        
	}
    
    [self configureView];
    
    [self reloadTableViewDataSource];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (IDIOM == IPHONE) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)loadAllRides
{    
    self.navigationItem.title = @"All Rides";
    
    [StravaManager fetchRideListWithCompletion:(^(NSArray *rides, NSError *error) {
        
        if (error) {
            
        } else {
            _rides = rides;
            [self.tableView performSelectorOnMainThread:@selector(reloadData) 
                                             withObject:nil 
                                          waitUntilDone:NO];
        }
    
        [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) 
                               withObject:nil 
                            waitUntilDone:NO];
    }) usingCache:NO];
}

//- (void)loadClubRides:(int)clubID
//{    
//    self.navigationItem.title = @"Club Rides";
//    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/rides?clubId=%d", clubID];    
//}

//- (void)loadAthleteRides:(NSString*)username
//{    
//    self.navigationItem.title = @"Athlete Rides";
//    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/rides?athleteName=%@", username];    
//}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rides.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    StravaRide *ride = (StravaRide*)[_rides objectAtIndex:indexPath.row];
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];                            

    textLabel.text = ride.name;
    
    [StravaManager fetchRideWithID:ride.id
                        completion:^(StravaRide *ride, NSError *error) {
                            
                            // todo:   maybe we should start loading them all once the tableview loads, instead of only loading the ones that appear on the screen
                            
                            UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:2];                            
                            detailTextLabel.text = ride.location;

                        }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IDIOM == IPAD) {

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        StravaRide *ride = (StravaRide*)[_rides objectAtIndex:indexPath.row];
        
        UISplitViewController *splitVC = (UISplitViewController*)[(UINavigationController*)[self parentViewController] parentViewController];

        RideViewController *vc = (RideViewController*)[(UINavigationController*)[[splitVC viewControllers] objectAtIndex:1] topViewController];
        
        [vc loadRideDetails:ride.id];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowRide"]) {

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        StravaRide *ride = (StravaRide*)[_rides objectAtIndex:indexPath.row];
        
        [(RideViewController *)[segue destinationViewController] setRideID:ride.id];
        
    }
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{    
	_reloading = YES;    
    
    // examples of how to load different subsets of rides:
    
    //[self loadClubRides:9];  
    //[self loadAthleteRides:@"jonkroll"];

    [self loadAllRides];
}

- (void)doneLoadingTableViewData
{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	    
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{    
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{    
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{    
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{    
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
