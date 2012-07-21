//
//  MKMapView+StravaManager.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (StravaManager)

- (void)setVisibleMapRectForAllOverlaysWithPadding:(UIEdgeInsets)insets;

@end
