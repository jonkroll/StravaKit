//
//  DetailViewController.h
//  StravaClub
//
//  Created by Jon Kroll on 5/23/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface RideListViewController : UITableViewController <UISplitViewControllerDelegate, EGORefreshTableHeaderDelegate>

@property (strong, nonatomic) id detailItem;

@property (nonatomic) int clubID;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

- (void)loadClubInfo;

@end
