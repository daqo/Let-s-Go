//
//  GVNewStatusViewController.h
//  Let's Go!
//
//  Created by Dave Qorashi on 6/16/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GVNewStatusViewController : UIViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *statusBody;
@property (weak, nonatomic) IBOutlet UILabel *statusError;

@end
