//
//  StravaClient.m
//  StravaClub
//
//  Created by Jon Kroll on 5/24/12.
//  Copyright (c) 2012 Optionetics, Inc. All rights reserved.
//

#import "StravaClient.h"
#import "StravaEffort.h"


@implementation StravaClient

+ (void)loadRide:(int)rideID delegate:(id<StravaClientDelegate>)delegate
{    
    NSString *urlString = [NSString stringWithFormat:@"http://www.strava.com/api/v1/rides/%d", rideID];
    
    [StravaClient stravaAPIRequest:(NSString*)urlString 
                         withBlock:^(id json) {
        
        NSDictionary *jsonDict = (NSDictionary*)json;        
        NSDictionary *rideInfo = [jsonDict objectForKey:@"ride"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];                  
        
        // fill object
        StravaRide *ride = [[StravaRide alloc] init];
        
        ride.id = rideID;
        ride.startDate = [rideInfo dateForKey:@"startDate"];
        ride.startDateLocal = [rideInfo dateForKey:@"startDateLocal"];
        ride.timeZoneOffset = [rideInfo intForKey:@"timeZoneOffset"];
        ride.elapsedTime = [rideInfo intForKey:@"elapsedTime"];
        ride.movingTime = [rideInfo intForKey:@"movingTime"];
        ride.distanceInMeters = [rideInfo doubleForKey:@"distance"];
        ride.distanceInMiles = [rideInfo doubleForKey:@"distance"]/ 1609.344;
        ride.averageSpeed = [rideInfo doubleForKey:@"averageSpeed"];
        ride.averageWatts = [rideInfo doubleForKey:@"averageWatts"];
        ride.maximumSpeed = [rideInfo doubleForKey:@"maximumSpeed"];                
        ride.elevationGainInMeters = [rideInfo intForKey:@"elevationGain"];
        ride.elevationGainInFeet = [rideInfo intForKey:@"elevationGain"] / 0.3048;
        ride.location = [rideInfo objectForKey:@"location"];
        ride.name = [rideInfo objectForKey:@"name"];
        
        NSDictionary* bikeInfo = [rideInfo objectForKey:@"bike"];                
        StravaBike *bike = [[StravaBike alloc] init];
        bike.id = [bikeInfo intForKey:@"id"];
        bike.name = [bikeInfo objectForKey:@"name"];
        ride.bike = bike;
        
        NSDictionary* athleteInfo = [rideInfo objectForKey:@"athlete"];                
        StravaAthlete *athlete = [[StravaAthlete alloc] init];
        athlete.id = [athleteInfo intForKey:@"id"];
        athlete.name = [athleteInfo objectForKey:@"name"];
        athlete.username = [athleteInfo objectForKey:@"username"];        
        ride.athlete = athlete;
        
        
        if ([delegate respondsToSelector:@selector(rideDidLoad:)]) {
            dispatch_sync(dispatch_get_main_queue(), ^{ 
                [delegate rideDidLoad:ride];
            });
        }
    }];
}

+ (void)loadMapRoute:(int)rideID delegate:(id<StravaClientDelegate>)delegate
{    
    NSString *urlString = [NSString stringWithFormat:@"http://www.strava.com/api/v1/stream/map/%d", rideID];
    
    [StravaClient stravaAPIRequest:(NSString*)urlString 
                         withBlock:^(id json) {

        NSArray *jsonArray = (NSArray*)json;
        int numPoints = jsonArray.count;
               
        // These points will store the bounding box of our route so we can easily zoom in on it.
        MKMapPoint northEastPoint, southWestPoint;
        
        CLLocationCoordinate2D* coordinateArray = malloc(sizeof(CLLocationCoordinate2D) * numPoints);
        
        int numCoordinates = 0;
        
        for (int i=0; i < numPoints; i++) {
            
            NSArray *latLonArr = [jsonArray objectAtIndex:i];
            
            CLLocationDegrees latitude = [[latLonArr objectAtIndex:0] doubleValue];
            CLLocationDegrees longitude = [[latLonArr objectAtIndex:1] doubleValue];
            
            if (latitude == 0.0 && longitude == 0.0) {
                
                // skip invalid point
                
            } else {
                                    
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                coordinateArray[numCoordinates] = coordinate;   
                
                MKMapPoint point = MKMapPointForCoordinate(coordinate);   

                if (numCoordinates == 0) {
                    northEastPoint = point;
                    southWestPoint = point;
                }
                else
                {
                    if (point.x > northEastPoint.x)
                        northEastPoint.x = point.x;
                    if(point.y > northEastPoint.y)
                        northEastPoint.y = point.y;
                    if (point.x < southWestPoint.x)
                        southWestPoint.x = point.x;
                    if (point.y < southWestPoint.y)
                        southWestPoint.y = point.y;
                }
                numCoordinates++;
            }
        }
        
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinateArray count:numCoordinates];
        MKMapRect boundingBox = MKMapRectMake(southWestPoint.x, 
                                              southWestPoint.y, 
                                              northEastPoint.x - southWestPoint.x, 
                                              northEastPoint.y - southWestPoint.y);
        
        // clear memory allocated earlier for the points
        free(coordinateArray);
        
        if ([delegate respondsToSelector:@selector(rideID:mapRouteDidLoad:boundingBox:)]) {
            dispatch_sync(dispatch_get_main_queue(), ^{ 
                [delegate rideID:rideID mapRouteDidLoad:polyline boundingBox:boundingBox];  
            });
        }
    }];
}

+ (void)loadRideEfforts:(int)rideID delegate:(id<StravaClientDelegate>)delegate 
{
    NSString *urlString = [NSString stringWithFormat:@"http://app.strava.com/api/v2/rides/%d/efforts", rideID];
    
    [StravaClient stravaAPIRequest:(NSString*)urlString 
                         withBlock:^(id json) {

         NSMutableArray *outputArray = [[NSMutableArray alloc] init];
                             
         NSDictionary *jsonDict = (NSDictionary*)json;        
         NSArray *effortsArray = [jsonDict objectForKey:@"efforts"];
                             
         for (NSDictionary *effortInfo in effortsArray) {
         
             NSDictionary *effortDict = [effortInfo objectForKey:@"effort"];             
             StravaEffort *effort = [[StravaEffort alloc] init];
             
             effort.id = [effortDict intForKey:@"id"];
             effort.startDateLocal = [effortDict dateForKey:@"start_date_local"];
             effort.elapsedTime = [effortDict intForKey:@"elapsed_time"];
             effort.movingTime = [effortDict intForKey:@"moving_time"];
             effort.distance = [effortDict doubleForKey:@"distance"];
             effort.averageSpeed = [effortDict doubleForKey:@"average_speed"];

             
             NSDictionary *segmentDict = [effortInfo objectForKey:@"segment"];
             StravaSegment *segment = [[StravaSegment alloc] init];
             
             segment.id = [segmentDict intForKey:@"id"];
             segment.name = [segmentDict objectForKey:@"name"];
             segment.climbCategory = [segmentDict intForKey:@"climb_category"];
             segment.averageGrade = [segmentDict doubleForKey:@"average_grade"];
             segment.elevationDifference = [segmentDict doubleForKey:@"elev_difference"];
             
             NSArray *startLoc = [segmentDict objectForKey:@"start_latlng"];
             NSArray *endLoc = [segmentDict objectForKey:@"end_latlng"];
             
             segment.startLatLong = CLLocationCoordinate2DMake([[startLoc objectAtIndex:0] doubleValue],
                                                               [[startLoc objectAtIndex:1] doubleValue]);
             segment.endLatLong = CLLocationCoordinate2DMake([[endLoc objectAtIndex:0] doubleValue],
                                                               [[endLoc objectAtIndex:1] doubleValue]);

             
             effort.segment = segment;
             
             [outputArray addObject:effort];
         }
                      
         if ([delegate respondsToSelector:@selector(rideID:rideEffortsDidLoad:)]) {
             dispatch_sync(dispatch_get_main_queue(), ^{ 
                 [delegate rideID:rideID rideEffortsDidLoad:[NSArray arrayWithArray:outputArray]];  
             });
         }
    }];
}


#pragma mark - Internal methods

+ (void)stravaAPIRequest:(NSString*)urlString withBlock:(void (^)(id))block {
    
    NSLog(@"%@",urlString);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            NSLog(@"ERROR: %@", error);

            // TODO:  sent error to delegate method
            
        } else {
            
            // parse JSON
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:receivedData
                                  options:NSJSONReadingMutableLeaves
                                  error:&error];
            if (error) {
                NSLog(@"ERROR: %@", error);
                
                // TODO:  sent error to delegate method

            } else {
                block(json);
            }
        }
    });
}
    
@end
