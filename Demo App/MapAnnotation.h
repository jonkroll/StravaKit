//
//  MapAnnotation.h
//  StravaClub
//
//  Created by Jon Kroll on 7/7/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
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
