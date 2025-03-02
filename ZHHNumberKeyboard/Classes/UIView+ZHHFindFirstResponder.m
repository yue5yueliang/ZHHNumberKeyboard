//
//  UIView+ZHHFindFirstResponder.m
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2025/3/2.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "UIView+ZHHFindFirstResponder.h"

@implementation UIView (ZHHFindFirstResponder)

/// 获取当前窗口中的第一响应者（适配 iOS 13.0+）
+ (UIView *)zhh_firstResponder {
    UIWindow *keyWindow = nil;

    // 通过 UIWindowScene 获取 keyWindow
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            keyWindow = scene.windows.firstObject;
            break;
        }
    }

    return [keyWindow zhh_findFirstResponder];
}

/// 递归查找第一响应者
- (UIView *)zhh_findFirstResponder {
    if ([self isFirstResponder]) {
        return self;
    }
    
    for (UIView *view in self.subviews) {
        UIView *responder = [view zhh_findFirstResponder];
        if (responder) {
            return responder;
        }
    }
    
    return nil;
}

@end
