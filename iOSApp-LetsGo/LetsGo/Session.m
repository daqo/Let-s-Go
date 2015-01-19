//
//  Session.m
//  MapDemo
//
//  Created by Dave Qorashi on 6/14/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import "Session.h"

@implementation Session
@synthesize token;
@synthesize userID;

static Session *instance = nil;

+(Session *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [Session new];
        }
    }
    return instance;
}

@end