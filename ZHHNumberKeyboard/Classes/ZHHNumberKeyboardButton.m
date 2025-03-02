//
//  ZHHNumberKeyboardButton.m
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2025/3/2.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHNumberKeyboardButton.h"
#import "ZHHNumberKeyboardHelper.h"

@implementation ZHHNumberKeyboardButton

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    UIImage *backgrouondImage = [ZHHNumberKeyboardHelper imageWithColor:backgroundColor size:CGSizeMake(1, 1)];
    [self setBackgroundImage:backgrouondImage forState:state];
}

@end
