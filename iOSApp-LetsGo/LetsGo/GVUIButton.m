//
//  GVUIButton.m
//  Let's Go!
//
//  Created by Dave Qorashi on 6/17/14.
//  Copyright (c) 2014 David Qorashi. All rights reserved.
//

#import "GVUIButton.h"

@implementation GVUIButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = self.bounds;
        [self addSubview:btn];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
