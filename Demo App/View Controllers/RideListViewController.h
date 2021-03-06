//
//  DetailViewController.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface RideListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate, EGORefreshTableHeaderDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) id detailItem;

@property (nonatomic) int clubID;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

- (void)loadRidesWithParameters:(NSDictionary*)parameters;

@end
