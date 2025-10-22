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

/// 为不同状态设置背景色（转换为背景图片）
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    UIImage *backgroundImage = [ZHHNumberKeyboardHelper imageWithColor:backgroundColor size:CGSizeMake(1, 1)];
    [self setBackgroundImage:backgroundImage forState:state];
}

@end
