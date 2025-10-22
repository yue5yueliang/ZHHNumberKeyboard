//
//  ZHHNumberKeyboardHelper.h
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2025/3/2.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 数字键盘辅助工具类
@interface ZHHNumberKeyboardHelper : NSObject
/// 获取数字键盘的默认 Frame
/// @return 适配屏幕的数字键盘 Frame
+ (CGRect)keyboardFrame;
/// 生成指定颜色和尺寸的图片
/// @param color 图片填充颜色
/// @param size 图片尺寸
/// @return 生成的 UIImage
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
/// 获取键盘的删除按钮图标（使用系统 SF Symbols）
/// @return 删除按钮的 UIImage
+ (UIImage *)deleteIcon;

/// 获取输入视图 (UITextInput) 中当前选中的文本范围
/// @param inputView 符合 UITextInput 协议的输入控件（如 UITextView、UITextField）
/// @return 当前选中的文本范围，返回 NSRange 结构体
+ (NSRange)selectedRangeInInputView:(id<UITextInput>)inputView;
/// 播放系统默认的输入点击音效（通常用于键盘点击）
+ (void)playClickAudio;

/// 根据给定颜色生成稍暗的颜色（用于高亮状态）
/// @param color 原始颜色
/// @param amount 亮度减少量（0-1之间）
/// @return 调暗后的颜色
+ (UIColor *)darkenColor:(UIColor *)color byAmount:(CGFloat)amount;

@end

NS_ASSUME_NONNULL_END
