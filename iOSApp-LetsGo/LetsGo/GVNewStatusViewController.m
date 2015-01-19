//
//  GVNewStatusViewController.m
//  Let's Go!
//
//  Created by Dave Qorashi on 6/16/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import "GVNewStatusViewController.h"
#import "Session.h"

@interface GVNewStatusViewController () {
    Session * sessionManager;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@end

@implementation GVNewStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10.0f;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    sessionManager = [Session getInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidLoad];
    [self.statusBody selectAll:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendButton:(id)sender {
    [self.statusBody resignFirstResponder];

    if (self.statusBody.text.length == 0) {
        self.statusError.text = @"Status body must be specified!";
    } else if (self.statusBody.text.length > 140) {
        self.statusError.text = @"Text must be less than 140 chars!";
    } else {
        NSString* lat = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude];
        NSString* lng = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude];
        NSString* duration = @"1200"; //TODO
        NSString* imageURL = @"http://www.something.com";

     
        NSArray *objects = [NSArray arrayWithObjects:lat, lng, self.statusBody.text, duration, imageURL, nil];
        
        NSArray *keys = [NSArray arrayWithObjects:@"lat", @"long", @"body", @"duration", @"image_url", nil];
        NSDictionary *statusInfo = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:statusInfo forKey:@"status"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonRequest = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSLog(@"jsonRequest is %@", jsonRequest);
        
        NSURL *url = [NSURL URLWithString:@"http://lets-go.herokuapp.com/statuses"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        
        NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:sessionManager.token forHTTPHeaderField:@"Authorization"];
        [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: requestData];
        
        //NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                       NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                       int statusCode = [httpResponse statusCode];
                                       if (statusCode == 201) {
                                           [self.navigationController popViewControllerAnimated: YES];
                                           
                                       } else if (statusCode == 422) {
                                           NSDictionary* errors = [result objectForKey:@"errors"];
                                           for(NSString* error in [errors allKeys]){
                                               if ([error isEqualToString:@"body"]) {
                                                   NSString* message = @"Status Body ";
                                                   for (NSString* errorMsg in [errors objectForKey:error]) {
                                                       message = [message stringByAppendingString:errorMsg];
                                                       message = [message stringByAppendingString:@"!"];
                                                   }
                                                   
                                                   self.statusError.text = message;
                                               }
                                           }

                                       }
                                   
                                    }];
    }
}




#pragma mark CLLocationManagerDelegate methods
- (void) locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
//    self.speedLabel.text = @"??";
//    self.locationLabel.text = @"Location Unavailable";
}

- (void) locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    // put resume code
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.currentLocation = location;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
