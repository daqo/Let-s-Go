//
//  GVLoginViewController.h
//  MapDemo
//
//  Created by Dave Qorashi on 6/14/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVLoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailLoginField;
@property (weak, nonatomic) IBOutlet UITextField *passwordLoginField;
@property (weak, nonatomic) IBOutlet UILabel *loginErrorLabel;

@end
