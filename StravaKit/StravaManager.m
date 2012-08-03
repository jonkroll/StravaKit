//
//  StravaManager.m
//  StravaKit
//
//  Created by Jon Kroll.
//  Copyright (c) 2012. All rights reserved.
//

#import "StravaManager.h"

#define BASE_URL @"http://www.strava.com"

@interface StravaManager ()

@property (nonatomic, strong) NSSet *pendingRequests;
@property (nonatomic, strong) NSCache *cache;

@end


@implementation StravaManager

@synthesize pendingRequests = _pendingRequests;
@synthesize cache = _cache;

#pragma mark - request management methods

+ (NSMutableSet*)pendingRequests
{
    static NSMutableSet* pendingRequests = nil;
    if (pendingRequests == nil)
    {
        pendingRequests = [[NSMutableSet alloc] init];
    }
    return pendingRequests;
}

+ (NSCache*)cache
{
    static NSCache* cache = nil;
    if (cache == nil)
    {
        cache = [[NSCache alloc] init];
    }
    return cache;
}

+ (void)cancelAllRequests
{
    [[self pendingRequests] removeAllObjects];
}


#pragma mark - Data Request methods

+ (void)fetchRideListWithParameters:(NSDictionary*)parameters
                         completion:(void (^)(NSArray *rides, NSError* error))completionHandler
                           useCache:(BOOL)useCache
{    
    NSMutableString *paramString = [[NSMutableString alloc] init];
    
    if (parameters) {
        for (NSString *key in parameters.allKeys) {
            NSString *keyValueString = [NSString stringWithFormat:@"%@=%@", key, [parameters valueForKey:key]];
            
            if ([paramString length] > 0) {
                [paramString appendFormat:@"&%@", keyValueString];
            } else {
                [paramString appendFormat:@"?%@", keyValueString];
            }
        }
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/rides%@", BASE_URL, paramString];
    
    [StravaManager stravaAPIRequest:(NSString*)urlString
                         useCache:useCache
                            handler:^(id json, NSError *error) {
    
        if (completionHandler) {
            if (error) {
                completionHandler(nil, error);
            } else {
                
                NSMutableArray *rides = [[NSMutableArray alloc] init];
                NSDictionary *jsonDict = (NSDictionary*)json;
                NSArray *jsonArray = [jsonDict objectForKey:@"rides"];
                
                for (NSDictionary *rideInfo in jsonArray) {
                    StravaRide *ride = [StravaRide rideFromDictionary:rideInfo];
                    [rides addObject:ride];
                }
                completionHandler([NSArray arrayWithArray:rides], nil);
            }
        }
    }];
}


+ (void)fetchRideWithID:(int)rideID 
      completion:(void (^)(StravaRide *ride, NSError *error))completionHandler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/rides/%d", BASE_URL, rideID];
    
    [StravaManager stravaAPIRequest:(NSString*)urlString 
                         useCache:YES
                          handler:^(id json, NSError *error) {
                              
        if (completionHandler) {
            if (error) {
                completionHandler(nil, error);
            } else {
                              
                NSDictionary *jsonDict = (NSDictionary*)json;        
                NSDictionary *rideInfo = [jsonDict objectForKey:@"ride"];
                StravaRide *ride = [StravaRide rideFromDictionary:rideInfo];
                
                completionHandler(ride, nil);
            }
        }
    }];
}

+ (void)fetchRideStreams:(int)rideID
              forStreams:(NSArray*)streams
              completion:(void (^)(NSDictionary *streams, NSError *error))completionHandler
{    
    NSMutableString *streamList = [[NSMutableString alloc] init];
    for (id streamName in streams) {
        if ([streamName isKindOfClass:[NSString class]]) {
            if ([streamList length] > 0) {
                [streamList appendString:@","];
            }
            [streamList appendString:streamName];
        }
    }
    
    if ([streamList length] > 0) { 
    
        NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/streams/%d?streams[]=%@", BASE_URL, rideID, streamList];
        
        [StravaManager stravaAPIRequest:(NSString*)urlString
                             useCache:YES
                             handler:^(id json, NSError *error) {
              
             if(completionHandler) {
                 if (error) {
                     completionHandler(nil, error);
                 }
                 NSDictionary *streams = (NSDictionary*)json;
                 completionHandler(streams, nil);
             }
        }];
    }

}

+ (void)fetchRideEfforts:(int)rideID
              completion:(void (^)(NSArray *efforts, NSError *error))completionHandler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/v2/rides/%d/efforts", BASE_URL, rideID];
    
    [StravaManager stravaAPIRequest:(NSString*)urlString 
                         useCache:YES
                            handler:^(id json, NSError *error) {
                             
         if (completionHandler) {
             if (error) {
                 completionHandler(nil, error);
             } else {
                 
                 NSMutableArray *outputArray = [[NSMutableArray alloc] init];
                 
                 NSDictionary *jsonDict = (NSDictionary*)json;        
                 NSArray *effortsArray = [jsonDict objectForKey:@"efforts"];
                 
                 for (NSDictionary *effortDict in effortsArray) {
                     
                     NSDictionary *effortInfo = [effortDict objectForKey:@"effort"];                                  
                     StravaEffort *effort = [StravaEffort effortFromDictionary:effortInfo];
                     [outputArray addObject:effort];
                 }
    
                 completionHandler(outputArray, nil);
             }
         } 
    }];
}


#pragma mark - Map Helper methods

+ (MKPolyline*)polylineForMapPoints:(NSArray*)latlng
{
    int numPoints = latlng.count;
    
    // These points will store the bounding box of our route so we can easily zoom in on it.
    MKMapPoint northEastPoint, southWestPoint;
    
    CLLocationCoordinate2D* coordinateArray = malloc(sizeof(CLLocationCoordinate2D) * numPoints);
    
    int numCoordinates = 0;
    
    for (int i=0; i < numPoints; i++) {
        
        NSArray *pointArr = [latlng objectAtIndex:i];
        
        CLLocationDegrees latitude = [[pointArr objectAtIndex:0] doubleValue];
        CLLocationDegrees longitude = [[pointArr objectAtIndex:1] doubleValue];
        
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

    
    // clear memory allocated earlier for the points
    free(coordinateArray);

    return polyline;
}


#pragma mark - Internal methods

+ (void)stravaAPIRequest:(NSString*)urlString 
              useCache:(BOOL)useCache
                 handler:(void (^)(id json, NSError *error))completionHandler
{
    id json;
    
    if (useCache) {
        // check if the response is already in the cache
        json = [[self cache] objectForKey:urlString];
    }
    
    if (json) {

        dispatch_async(dispatch_get_main_queue(), ^{ completionHandler(json, nil); });
    
    } else {
    
        NSLog(@"%@", urlString);

        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [[self pendingRequests] addObject:request];
        
        [NSURLConnection sendAsynchronousRequest:request 
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                    NSData *receivedData,
                                                    NSError *error) {
                                   
            // ensure that request has not been cancelled
            if ([[self pendingRequests] containsObject:request]) {
                
                [[self pendingRequests] removeObject:request];
                                   
                if (error) {
                    completionHandler(nil, error);
                } else {
                    
                    // parse JSON
                    id json = [NSJSONSerialization
                                      JSONObjectWithData:receivedData
                                      options:NSJSONReadingMutableLeaves
                                      error:&error];
                    if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{ 
                            completionHandler(nil, error);
                        });
                    } else {
                        
                        // add response to cache
                        [[self cache] setObject:json forKey:urlString];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{                         
                            completionHandler(json, nil);  
                        });                        
                    }
                }
            }                       
        }];
    }
}
    
@end
