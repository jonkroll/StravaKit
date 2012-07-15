//
//  MKMapView+MapRectForOverlays.m
//  StravaClub
//
//  Created by Jon Kroll on 7/9/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import "MKMapView+MapRectForOverlays.h"

@implementation MKMapView (MapRectForOverlays)

- (void)setVisibleMapRectForAllOverlaysWithPadding:(UIEdgeInsets)insets
{
    MKMapRect totalRect = MKMapRectNull;
    for (id<MKOverlay> overlay in self.overlays) {
        totalRect = MKMapRectUnion(totalRect, overlay.boundingMapRect);
    }    
    [self setVisibleMapRect:[self mapRectThatFits:totalRect edgePadding:insets]];
}

@end
