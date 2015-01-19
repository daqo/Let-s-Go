//
//  Session.h
//  MapDemo
//
//  Created by Dave Qorashi on 6/14/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Session : NSObject {
    NSString *token;
    NSString *userID;
}
@property(retain, nonatomic) NSString* token;
@property(retain, nonatomic) NSString* userID;
+(Session*)getInstance;
@end