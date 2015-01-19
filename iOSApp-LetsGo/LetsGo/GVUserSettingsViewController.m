//
//  GVUserSettingsViewController.m
//  MapDemo
//
//  Created by Dave Qorashi on 6/15/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import "GVUserSettingsViewController.h"
#import "Session.h"

@interface GVUserSettingsViewController ()

@end

@implementation GVUserSettingsViewController

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
    Session *sessionManager = [Session getInstance];
    // Do any additional setup after loading the view.
    self.userIdLabel.text = sessionManager.userID;
    self.tokenIdLabel.text = sessionManager.token;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
