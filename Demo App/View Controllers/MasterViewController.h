//
//  MasterViewController.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RideListViewController;

@interface MasterViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) RideListViewController *detailViewController;

@end
