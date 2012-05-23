//
//  MasterViewController.h
//  StravaClub
//
//  Created by Jon Kroll on 5/23/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
