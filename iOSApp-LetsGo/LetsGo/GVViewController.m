//
//  GVViewController.m
//  MapDemo
//
//  Created by Dave Qorashi on 6/5/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import "GVViewController.h"
#import "GVCustomizedCalloutController.h"
#import "UIPopoverController+iPhone.h"
#import "UICKeyChainStore.h"
#import "Session.h"
#import "Reachability.h"
#import "GVUIButton.h"


@interface GVViewController () {
    Session *sessionManager;
}
@property (nonatomic, strong) UIPopoverController *_popover;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSArray *statuses;
@end

@implementation GVViewController
- (IBAction)composeStatusButton:(id)sender {
    [self performSegueWithIdentifier:@"composeStatus" sender:self.view];
  
}

- (void)fetchNewAnnotaions {
    [self.map removeAnnotations:self.map.annotations];
    NSArray *objects = [NSArray array];
    NSArray *keys = [NSArray array];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonRequest = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonRequest is %@", jsonRequest);
    
    NSURL *url = [NSURL URLWithString:@"http://lets-go.herokuapp.com/statuses/list"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:sessionManager.token forHTTPHeaderField:@"Authorization"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                               int statusCode = [httpResponse statusCode];
                               if (statusCode == 200) {
                                   NSArray* points = [result objectForKey:@"statuses"];
                                   self.statuses = points;
                                   NSMutableArray* annotations = [NSMutableArray array];
                                   for (id point in points) {
                                       NSString* creatorName = [point objectForKey:@"creator_name"];
                                       NSString* creatorID = [point objectForKey:@"creator_id"];
                                       NSString* body = [point objectForKey:@"body"];
                                       NSString* created_at = [point objectForKey:@"created_at"];
                                       NSString* lat = [point objectForKey:@"lat"];
                                       NSString* lng = [point objectForKey:@"long"];
                                       NSString* imageURL = [point objectForKey:@"image_url"];
                                       NSDictionary *inventory;
                                       if ([creatorID isEqualToString:sessionManager.userID]) {
                                           inventory = @{ @"title": body, @"subtitle": @"Posted By: You", @"lat": lat, @"long": lng
                                                          };
                                       } else {
                                           NSMutableString * subtitleText = [[NSMutableString alloc] initWithString:@"Posted By: "];
                                           [subtitleText appendString:creatorName];
                                           inventory = @{ @"title": body, @"subtitle": subtitleText, @"lat": lat, @"long": lng
                                                          };
                                       }
                                       
                                       [annotations addObject:inventory];
                                   }
                                   for(NSDictionary *point in annotations) {
                                       MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
                                       myAnnotation.coordinate = CLLocationCoordinate2DMake([point[@"lat"] floatValue],
                                                                                            [point[@"long"] floatValue]);
                                       myAnnotation.title = point[@"title"];
                                       myAnnotation.subtitle = point[@"subtitle"];
                                       [self.map addAnnotation:myAnnotation];
                                   }
                                   [self.map showAnnotations:self.map.annotations animated:NO];
                               }
                               
                           }];
    
    
}


- (IBAction)toggleMap:(id)sender {
    [self.map setHidden:![self.map isHidden]];
}
- (IBAction)logoutButton:(id)sender {
    [UICKeyChainStore removeItemForKey:@"userToken"];
    [self.navigationController popToRootViewControllerAnimated:NO];

}


- (IBAction)dismissPopover:(id)sender {
    if (self._popover) {
        [self._popover dismissPopoverAnimated:YES];
        self._popover = nil;
        return;
    }
}

- (IBAction)sendSMS:(id)sender {
    if (self._popover) {
        [self._popover dismissPopoverAnimated:YES];
        self._popover = nil;
    }
    NSLog(@"%@",[(GVUIButton *)sender phoneNumber]);
    self.phoneNumber = [(GVUIButton *)sender phoneNumber];

    //[self performSegueWithIdentifier:@"sendSMSSegue" sender:self];
    [self showSMS];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView* noInternet = [[UIAlertView alloc]
         initWithTitle:@"Connectivity Problem" message:@"There is no internet connection" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil];
        [noInternet show];
        NSLog(@"There IS NO internet connection");
        
    } else {
        NSLog(@"There IS internet connection");
        [self fetchNewAnnotaions];
    }


}

- (void)viewDidLoad
{
    [super viewDidLoad];
    sessionManager = [Session getInstance];
	// Do any additional setup after loading the view, typically from a nib.

    
    self.map.delegate = self;
    self.map.showsUserLocation = YES;
    self.map.userTrackingMode = YES;
    self.navigationItem.hidesBackButton = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:60
                                target:self
                                selector:@selector(fetchNewAnnotaions)
                                userInfo:nil
                                repeats:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *identifier = @"myAnnotation";
    MKPinAnnotationView * pinView = (MKPinAnnotationView*)[self.map dequeueReusableAnnotationViewWithIdentifier:identifier];
    pinView.animatesDrop = NO;
    if (!pinView)
    {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        if ([annotation.subtitle isEqualToString:@"Posted By: You"]) {
            pinView.pinColor = MKPinAnnotationColorPurple;
        } else {
            pinView.pinColor = MKPinAnnotationColorGreen;
        }

        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
    } else {
        if ([annotation.subtitle isEqualToString:@"Posted By: You"]) {
            pinView.pinColor = MKPinAnnotationColorPurple;
        } else {
            pinView.pinColor = MKPinAnnotationColorGreen;
        }
        pinView.annotation = annotation;
    }
    
    // Add a disclosure button.
    pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    // Add a left image on callout bubble.
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"honeybee.png"]];
    pinView.leftCalloutAccessoryView = iconView;
    return pinView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    id <MKAnnotation> annotation = [view annotation];
    
    if (self._popover) {
        [self._popover dismissPopoverAnimated:YES];
        self._popover = nil;
        return;
    }
    
    GVCustomizedCalloutController * ycvc = [[GVCustomizedCalloutController alloc] init];
    UILabel *myLabel1  =  [[UILabel alloc]init];
    myLabel1.font=[UIFont boldSystemFontOfSize:15];
    myLabel1.frame     =  CGRectMake(10,0,185,120);
    myLabel1.text      =  annotation.title;
    myLabel1.numberOfLines = 0;
    [ycvc.view addSubview:myLabel1];

    UILabel *myLabel2 =  [[UILabel alloc]init];
    myLabel2.font=[UIFont systemFontOfSize:13];
    myLabel2.frame     =  CGRectMake(10,80,185,100);
    myLabel2.text      =  annotation.subtitle;
    myLabel2.numberOfLines = 0;
    [ycvc.view addSubview:myLabel2];
    
    UILabel *myLabel3 =  [[UILabel alloc]init];
    myLabel3.font=[UIFont systemFontOfSize:13];
    myLabel3.frame     =  CGRectMake(10,100,185,100);
    myLabel3.text      =  @"10 minutes ago";
    myLabel3.numberOfLines = 0;
    [ycvc.view addSubview:myLabel3];
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dismissButton addTarget:self action:@selector(dismissPopover:) forControlEvents:UIControlEventTouchUpInside];
    [dismissButton setTitle:@"Close" forState:UIControlStateNormal];
    dismissButton.frame = CGRectMake(10.0, 150.0, 60.0, 60.0);
    [ycvc.view addSubview:dismissButton];
    
    if (![annotation.subtitle isEqualToString:@"Posted By: You"]) {
        
        NSString* creatorPhoneNumber;
        for (id point in self.statuses) {
            if([myLabel1.text isEqualToString:[point objectForKey:@"body"]]) {
                creatorPhoneNumber = [point objectForKey:@"image_url"];
                break;
            }
        }
        
        
        
        GVUIButton *smsButton = [GVUIButton buttonWithType:UIButtonTypeRoundedRect];
        smsButton.phoneNumber = creatorPhoneNumber;
        [smsButton addTarget:self action:@selector(sendSMS:) forControlEvents:UIControlEventTouchUpInside];
        [smsButton setTitle:@"Message" forState:UIControlStateNormal];
        smsButton.frame = CGRectMake(110.0, 150.0, 90.0, 60.0);
        if (!annotation.subtitle) {
            [smsButton setEnabled:false];
        }
        [ycvc.view addSubview:smsButton];
    }
    
    ycvc.contentSizeForViewInPopover = CGSizeMake(200, 200);
    self._popover = [[UIPopoverController alloc] initWithContentViewController:ycvc];
    self._popover.delegate = self;
    [self._popover presentPopoverFromRect:view.bounds inView:view
                 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
    
//    if ([annotation isKindOfClass:[MKPointAnnotation class]])
//    {
//        NSLog(@"Clicked an Annotation");
//    }
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Disclosure Pressed" message:@"Click Cancel to Go Back" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    [alertView show];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"settings"] || [identifier isEqualToString:@"composeStatus"] ) {
         return YES;
    }
    return NO;
}


- (void)showSMS {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = [NSArray arrayWithObject:self.phoneNumber];
    NSString *message = [NSString stringWithFormat:@"Find you on Let's Go! How is it going!?"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            NSLog(@"dsdsds");
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPopoverController Delegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self._popover = nil;
}


@end
