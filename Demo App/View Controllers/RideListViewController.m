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
    
    NSMutableArray *_rides;
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
    // Update the user interface for the detail item (iPad version)

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // override default text on back button when we go to detail view controller 
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	
    // insert logo into nav bar
    UIImageView* logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavLogo.png"]];
    self.navigationItem.titleView = logo;
    
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

- (void)loadRidesWithParameters:(NSDictionary*)parameters
{
    
    [StravaManager fetchRideListWithParameters:parameters
                                    completion:(^(NSArray *rides, NSError *error) {
        
        if (error) {
            NSLog(@"ERROR: %@", error);
        } else {
            
            _rides = [NSMutableArray arrayWithArray:rides];

            [self.tableView reloadData];
            [self doneLoadingTableViewData];
            
            if (_rides && IDIOM == IPAD) {
                UISplitViewController *splitVC = (UISplitViewController*)[(UINavigationController*)[self parentViewController] parentViewController];
                RideViewController *vc = (RideViewController*)[(UINavigationController*)[[splitVC viewControllers] objectAtIndex:1] topViewController];
                
                // show the first ride in the detail view if no ride is showing yet
                if (!vc.rideID) {
                    StravaRide *ride = (StravaRide*)[_rides objectAtIndex:0];
                    [self showRideInDetailView:ride.id];
                }
            }
            
            // fetchRideListWithParameters only returns the rideName and rideID
            // loop through the array now to fetch the rest of the details for each ride
            for (int i=0; i < [rides count]; i++) {
            
                [StravaManager fetchRideWithID:[[rides objectAtIndex:i] id]
                                    completion:^(StravaRide *ride, NSError *error) {
                                        
                    if (error) {
                        NSLog(@"ERROR: %@", error);
                    } else {
                        [_rides replaceObjectAtIndex:i withObject:ride];  // ride contains complete ride info now
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
                    }
                }];
            }
        }
        
    }) useCache:NO];
}

- (void)showRideInDetailView:(int)rideID
{
    if (IDIOM == IPAD) {
        
        UISplitViewController *splitVC = (UISplitViewController*)[(UINavigationController*)[self parentViewController] parentViewController];
        RideViewController *vc = (RideViewController*)[(UINavigationController*)[[splitVC viewControllers] objectAtIndex:1] topViewController];
        
        if (vc.rideID != rideID) {  // don't reload if we are already showing the targeted ride
            [vc loadRideDetails:rideID];
        }

    }
}


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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell"];
    
    StravaRide *ride = (StravaRide*)[_rides objectAtIndex:indexPath.row];
    
    UILabel *textLabel = (UILabel*)[[cell contentView] viewWithTag:1];
    UILabel *detailTextLabel = (UILabel*)[[cell contentView] viewWithTag:2];

    textLabel.text = ride.name;
    
    if (ride.location) {
        detailTextLabel.text = [NSString stringWithFormat:@"%@ • %.1f mi", ride.location, ride.distanceInMiles];
    } else {
        detailTextLabel.text = @"";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IDIOM == IPAD) {

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        StravaRide *ride = (StravaRide*)[_rides objectAtIndex:indexPath.row];
        [self showRideInDetailView:ride.id];
        
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
        
    NSDictionary * parameters = nil;

    // examples of how to load different subsets of rides:

    //NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"9", @"clubId", nil];
    //NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"jonkroll", @"athleteName", nil];
    
    
    [self loadRidesWithParameters:parameters];
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
