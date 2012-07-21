//
//  MapAnnotation.m
//  StravaClub
//
//  Created by Jon Kroll on 7/7/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

@synthesize coordinate = _coordinate;
@synthesize tag = _tag;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                withTag:(NSUInteger)tag
              withTitle:(NSString *)title
           withSubtitle:(NSString *)subtitle	
{
	if (self = [super init]) {
		_coordinate = coordinate;
		_tag = tag;
		_title = title;
		_subtitle = subtitle;
	}    
	return self;
}

@end
