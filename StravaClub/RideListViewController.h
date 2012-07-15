//
//  DetailViewController.h
//  StravaClub
//
//  Created by Jon Kroll on 5/23/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface RideListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate, EGORefreshTableHeaderDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) id detailItem;

@property (nonatomic) int clubID;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

- (void)loadClubRides:(int)clubID;
- (void)loadAthleteRides:(NSString*)username;

@end
