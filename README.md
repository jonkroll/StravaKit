StravaKit for iOS
=============

An Objective-C wrapper for interacting with the Strava (http://www.strava.com) v1 API.


StravaKit Notes
-------------

For iOS 5.0 and above.

The `StravaManager` class provides static methods for fetching data and uses blocks-based callbacks for interacting wth the data once received from the Strava API.  Here is an example usage:


    [StravaManager fetchRideWithID:rideID completion:(^(StravaRide *ride, NSError *error) {

            if (error) {
                NSLog(@"Error fetching ride data: @%", [error localizedDescription]);
            } else {
                NSString *description = ride.description;
                NSDate *startDate = ride.startDate;
                // etc...
            }
    })];


Demo App Notes
-------------

A demo app is included to show the usage of StravaKit in more detail.  This demo app is a universal app for iPad and iPhone.

The table view controller will show the fifty most recent rides that have been uploaded to Strava.  Pull down on the table view to refresh the list (new rides are constantly beng added.)  When viewing an activity's details, tap on the map view to see the route full screen.  In the iPhone version, swipe on the map view to show the elevation chart.  The Actions menu button on the upper right allows the user to email a link to the activity or to open the Strava web page for the activity in the mobile browser.

Here are some screen shots:

### iPad Version




### iPhone Version





Credit to Open Source iOS Libraries used in the Demo App
-------------

- [EGOTableViewPullRefresh](https://github.com/enormego/EGOTableViewPullRefresh), a "pull to refresh" control for UITableView.
- [DDPageControl](https://github.com/ddeville/DDPageControl), a customizable alternative to UIKit's UIPageControl
- [gRafael](http://g.raphaeljs.com/), a javascript library for for drawing charts, used in a UIWebView


Areas for Improvement
-------------

* Complete implementation of StravaManager class for remaining Strava API v1 REST methods.


Ideas for future enhancement to demo app:

* Update demo app to support landscape orientation (for iPhone) and portrait (for iPad)
* Switch from javascript charting to CorePlot-based charting
* Allow user to switch between a list of all rides and a list of only his/her own rides, or club rides
* Add ability to drill into ride segments


Thoughts/Questions/Improvements?
-------------
Send them to jonkroll@gmail.com