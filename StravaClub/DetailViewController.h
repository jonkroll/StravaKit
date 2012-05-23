//
//  DetailViewController.h
//  StravaClub
//
//  Created by Jon Kroll on 5/23/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
