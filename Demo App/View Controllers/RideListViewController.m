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
    
    NSMutableArray *_objects;
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
    NSString *urlString = [NSString stringWithFormat:@"http://app.strava.com/api/v1/rides"];    
    [self loadRides:urlString];
}

- (void)loadClubRides:(int)clubID
{    
    self.navigationItem.title = @"Club Rides";
    NSString *urlString = [NSString stringWithFormat:@"http://app.strava.com/api/v1/rides?clubId=%d", clubID];    
    [self loadRides:urlString];
}

- (void)loadAthleteRides:(NSString*)username
{    
    self.navigationItem.title = @"Athlete Rides";
    NSString *urlString = [NSString stringWithFormat:@"http://app.strava.com/api/v1/rides?athleteName=%@", username];    
    [self loadRides:urlString];
}

- (void)loadRides:(NSString*)urlString
{    
    NSLog(@"%@",urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        if (error) {
            NSLog(@"%@", error);
        } else {
        
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:receivedData
                                  options:NSJSONReadingMutableLeaves
                                  error:&error];
            
            if (error) {
                NSLog(@"%@", error);                
            } else {
            
                NSArray *rides = [json objectForKey:@"rides"];
                _objects = [NSArray arrayWithArray:rides];
                
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                
            }
        }
        
        [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:NO];
        
    });
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *object = [_objects objectAtIndex:indexPath.row];
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];                            

    textLabel.text = [object objectForKey:@"name"];
    //cell.detailTextLabel.text = @"";
            
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"id"]];
    
    [StravaManager fetchRideWithID:[[object objectForKey:@"id"] intValue]
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
        NSString *object = [_objects objectAtIndex:indexPath.row];
        
        int rideID = [(NSNumber*)[(NSDictionary *)object objectForKey:@"id"] intValue];

        UISplitViewController *splitVC = (UISplitViewController*)[(UINavigationController*)[self parentViewController] parentViewController];

        RideViewController *vc = (RideViewController*)[(UINavigationController*)[[splitVC viewControllers] objectAtIndex:1] topViewController];
        
        [vc loadRideDetails:rideID];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{


    if ([[segue identifier] isEqualToString:@"ShowRide"]) {

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *object = [_objects objectAtIndex:indexPath.row];
                
        int rideID = [(NSNumber*)[(NSDictionary *)object objectForKey:@"id"] intValue];
        
        [(RideViewController *)[segue destinationViewController] setRideID:rideID];
        
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
