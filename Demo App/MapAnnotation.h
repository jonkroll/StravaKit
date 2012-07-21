//
//  MapAnnotation.h
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSUInteger tag;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate 
                withTag:(NSUInteger)tag
              withTitle:(NSString *)title 
           withSubtitle:(NSString *)subtitle;	
@end
