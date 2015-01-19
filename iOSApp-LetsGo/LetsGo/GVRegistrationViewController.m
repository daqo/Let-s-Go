//
//  GVRegistrationViewController.m
//  MapDemo
//
//  Created by Dave Qorashi on 6/12/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import "GVRegistrationViewController.h"
#import "Session.h"
#import "UICKeyChainStore.h"

@interface GVRegistrationViewController () {
    NSMutableData *_registrationResponse;
    NSString* _accessToken;
    Session *sessionManager;
    UICKeyChainStore *_store;
}
@end

@implementation GVRegistrationViewController

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
    [self.userName setDelegate:self];
    [self.fullName setDelegate:self];
    [self.email setDelegate:self];
    [self.password setDelegate:self];
    [self.passwordConfirmation setDelegate:self];
    
    sessionManager = [Session getInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)registerButton:(id)sender {
    self.usernameError.text = @"";
    self.emailError.text = @"";
    self.nameError.text = @"";
    self.passwordError.text = @"";
    self.phoneNumberError.text = @"";
    NSArray *objects = [NSArray arrayWithObjects:self.userName.text, self.fullName.text, self.email.text, self.phoneNumber.text, self.password.text, self.passwordConfirmation.text, nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"username", @"name", @"email", @"phone_number", @"password", @"password_confirmation", nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:userInfo forKey:@"user"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonRequest = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonRequest is %@", jsonRequest);
    
    NSURL *url = [NSURL URLWithString:@"http://lets-go.herokuapp.com/users"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    //NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                               int statusCode = [httpResponse statusCode];
                               if (statusCode == 201) {
                                   NSDictionary* apiKey = [result objectForKey:@"api_key"];
                                   _accessToken = [apiKey objectForKey:@"access_token"];
                                   NSString* _userID = @"#";
                                   _userID = [_userID stringByAppendingString:                                   [NSString stringWithFormat:@"%@", [apiKey objectForKey:@"user_id"]]];

                                   sessionManager.token = _accessToken;
                                   sessionManager.userID = _userID;
                                   
                                   [UICKeyChainStore setString:_accessToken forKey:@"userToken"];
                                   [UICKeyChainStore setString:_userID forKey:@"userID"];
                                   
                                   [_store synchronize];
                                   
                                   [self performSegueWithIdentifier:@"goToMainPageFromRegistration" sender:self];
                                   
                               } else if (statusCode == 422) {
                                   NSDictionary* errors = [result objectForKey:@"errors"];
                                   for(NSString* error in [errors allKeys]){
                                       if ([error isEqualToString:@"username"]) {
                                           NSString* message = @"User Name ";
                                           for (NSString* errorMsg in [errors objectForKey:error]) {
                                               message = [message stringByAppendingString:errorMsg];
                                               message = [message stringByAppendingString:@";"];
                                           }
                                           
                                           self.usernameError.text = message;
                                       } else if([error isEqualToString:@"name"]) {
                                           NSString* message = @"Name ";
                                           for (NSString* errorMsg in [errors objectForKey:error]) {
                                               message = [message stringByAppendingString:errorMsg];
                                               message = [message stringByAppendingString:@";"];
                                           }
                                           
                                           self.nameError.text = message;
                                       } else if([error isEqualToString:@"password"] || [error isEqualToString:@"password_confirmation"]) {
                                           NSString* message = @"Password ";
                                           for (NSString* errorMsg in [errors objectForKey:error]) {
                                               message = [message stringByAppendingString:errorMsg];
                                               message = [message stringByAppendingString:@";"];
                                           }
                                           self.passwordError.text = message;
                                       } else if([error isEqualToString:@"email"]) {
                                           NSString* message = @"Email ";
                                           for (NSString* errorMsg in [errors objectForKey:error]) {
                                               message = [message stringByAppendingString:errorMsg];
                                               message = [message stringByAppendingString:@";"];
                                           }
                                           
                                           self.emailError.text = message;
                                       } else if([error isEqualToString:@"phone_number"]) {
                                           NSString* message = @"Phone Number ";
                                           for (NSString* errorMsg in [errors objectForKey:error]) {
                                               message = [message stringByAppendingString:errorMsg];
                                               message = [message stringByAppendingString:@";"];
                                           }
                                           
                                           self.phoneNumberError.text = message;
                                       }

                                       
                                   }
                               }
                               
                           }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"goToMainPageFromRegistration"] ) {
        return NO;
    }
    return YES;
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
