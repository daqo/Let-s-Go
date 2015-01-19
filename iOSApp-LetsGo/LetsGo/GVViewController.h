//
//  GVViewController.h
//  MapDemo
//
//  Created by Dave Qorashi on 6/5/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>

@interface GVViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UIPopoverControllerDelegate,MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet MKMapView *map;

@end
