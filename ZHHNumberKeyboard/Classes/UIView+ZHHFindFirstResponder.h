//
//  UIView+ZHHFindFirstResponder.h
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2025/3/2.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 查找当前界面的第一响应者
@interface UIView (ZHHFindFirstResponder)

/// 获取当前窗口中的第一响应者
/// @return 当前正在响应输入的 UIView（如果存在）
+ (nullable UIView *)zhh_firstResponder;

@end

NS_ASSUME_NONNULL_END
