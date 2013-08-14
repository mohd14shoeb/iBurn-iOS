#import "MyCLController.h"
#import "iBurnAppDelegate.h"
#import "RMMapView.h"

// This is a singleton class, see below
static MyCLController *sharedCLDelegate = nil;
@implementation MyCLController
@synthesize delegate, locationManager, lastReading,location;

- (id) init {
	if (self = [super init]) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self; 
	}
	return self;
}


#warning duplicated code
BOOL sphericalTrapeziumContainsPoint(RMSphericalTrapezium rect, CLLocationCoordinate2D point) {
  return (rect.northEast.latitude > point.latitude && rect.southWest.latitude < point.latitude &&
          rect.northEast.longitude > point.longitude && rect.southWest.longitude < point.longitude);
}


// Called when the location is updated
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
  location = newLocation;
	[self.delegate newLocationUpdate:newLocation];
#warning bounds are wrong
  RMSphericalTrapezium bounds = ((RMSphericalTrapezium){.northEast = {.latitude = 40.802822, .longitude = -119.172673},
    .southWest = {.latitude = 40.759210, .longitude = -119.23454}});
  if (sphericalTrapeziumContainsPoint(bounds, newLocation.coordinate)) {
    iBurnAppDelegate *t = (iBurnAppDelegate *)[[UIApplication sharedApplication] delegate];
    [t liftEmbargo];
  }
}


// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {}


+ (MyCLController *)sharedInstance {
  @synchronized(self) {
    if (sharedCLDelegate == nil) {
      sharedCLDelegate = [[self alloc] init]; // assignment not done here
    }
  }
  return sharedCLDelegate;
}


- (void)dealloc {
  delegate = nil;
}


- (double) currentDistanceToLocation:(CLLocation*)location {
  return [location distanceFromLocation: locationManager.location];
}


@end