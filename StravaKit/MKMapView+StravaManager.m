//
//  MKMapView+StravaManager.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import "MKMapView+StravaManager.h"
#import "MapAnnotation.h"

@implementation MKMapView (StravaManager)

- (void)setVisibleMapRectForAllOverlaysWithPadding:(UIEdgeInsets)insets
{
    MKMapRect totalRect = MKMapRectNull;
    for (id<MKOverlay> overlay in self.overlays) {
        totalRect = MKMapRectUnion(totalRect, overlay.boundingMapRect);
    }    
    [self setVisibleMapRect:[self mapRectThatFits:totalRect edgePadding:insets]];
}

- (void)addRouteLine:(MKPolyline*)polyline showEndpoints:(BOOL)showEndpoints
{        
    [self addOverlay:polyline];
    
    if (showEndpoints) {
        int numPoints = polyline.pointCount;
        
        CLLocationCoordinate2D startCoordinate = MKCoordinateForMapPoint(polyline.points[0]);
        MapAnnotation *startAnnotation = [[MapAnnotation alloc] initWithCoordinate:startCoordinate
                                                                           withTag:0
                                                                         withTitle:nil 
                                                                      withSubtitle:nil];
            
        CLLocationCoordinate2D endCoordinate = MKCoordinateForMapPoint(polyline.points[numPoints-1]);
        MapAnnotation *endAnnotation = [[MapAnnotation alloc] initWithCoordinate:endCoordinate
                                                                         withTag:1
                                                                       withTitle:nil 
                                                                    withSubtitle:nil];
        
        NSArray *annotations = [NSArray arrayWithObjects:startAnnotation, endAnnotation, nil];
        

        [self addAnnotations:annotations];
    }
}

@end
