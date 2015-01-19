//
//  GVLoginViewController.m
//  MapDemo
//
//  Created by Dave Qorashi on 6/14/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import "GVLoginViewController.h"
#import "Session.h"
#import "UICKeyChainStore.h"

@interface GVLoginViewController () {
    NSMutableData *_loginResponse;
    NSString* _accessToken;
    Session *sessionManager;
    UICKeyChainStore* _store;
}
@end

@implementation GVLoginViewController
- (IBAction)loginButton:(id)sender {
    if([self.emailLoginField isFirstResponder]){
        [self.emailLoginField resignFirstResponder];
    }
    
    if([self.passwordLoginField isFirstResponder]){
        [self.passwordLoginField resignFirstResponder];
    }
    
    
    NSArray *objects = [NSArray arrayWithObjects:self.emailLoginField.text, self.passwordLoginField.text, nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"username_or_email", @"password", nil];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonRequest = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonRequest is %@", jsonRequest);
    
    NSURL *url = [NSURL URLWithString:@"http://lets-go.herokuapp.com/session"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
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

                                   
                                   [self performSegueWithIdentifier:@"goToMainPage" sender:self];
                                   [self.loginErrorLabel setHidden:true];
                                   
                               } else {
                                   [self.loginErrorLabel setHidden:false];
                               }
                               
                           }];
}
- (IBAction)registerPageButton:(id)sender {
    [self performSegueWithIdentifier:@"goToRegisterPage" sender:self];
}

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
    sessionManager = [Session getInstance];
    // Do any additional setup after loading the view.
    self.navigationController.toolbarHidden = NO;
    [self.emailLoginField setDelegate:self];
    [self.passwordLoginField setDelegate:self];
    NSString* token = [UICKeyChainStore stringForKey:@"userToken"];
    NSString* userID = [UICKeyChainStore stringForKey:@"userID"];
    if (token != nil) {
        sessionManager.userID = userID;
        sessionManager.token = token;
        [self performSegueWithIdentifier:@"goToMainPage" sender:self];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.emailLoginField.text = @"";
    self.passwordLoginField.text = @"";
    [self.loginErrorLabel setHidden:true];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"goToMainPage"] ) {
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
