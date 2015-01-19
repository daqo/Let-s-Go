//
//  GVRegistrationViewController.h
//  MapDemo
//
//  Created by Dave Qorashi on 6/12/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVRegistrationViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *fullName;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmation;
@property (weak, nonatomic) IBOutlet UILabel *usernameError;
@property (weak, nonatomic) IBOutlet UILabel *emailError;
@property (weak, nonatomic) IBOutlet UILabel *nameError;
@property (weak, nonatomic) IBOutlet UILabel *passwordError;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberError;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;

@end
