//
//  MKMapView+StravaManager.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import "MKMapView+StravaManager.h"

@implementation MKMapView (StravaManager)

- (void)setVisibleMapRectForAllOverlaysWithPadding:(UIEdgeInsets)insets
{
    MKMapRect totalRect = MKMapRectNull;
    for (id<MKOverlay> overlay in self.overlays) {
        totalRect = MKMapRectUnion(totalRect, overlay.boundingMapRect);
    }    
    [self setVisibleMapRect:[self mapRectThatFits:totalRect edgePadding:insets]];
}

@end
