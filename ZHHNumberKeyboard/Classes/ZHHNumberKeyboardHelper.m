//
//  ZHHNumberKeyboardHelper.m
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2025/3/2.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHNumberKeyboardHelper.h"

@implementation ZHHNumberKeyboardHelper

+ (UIEdgeInsets)safeAreaInsets {
    UIWindow *window = nil;

    // 通过 UIWindowScene 获取当前 keyWindow（适配 iOS 13.0+）
    NSSet<UIScene *> *scenes = UIApplication.sharedApplication.connectedScenes;
    for (UIScene *scene in scenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *w in windowScene.windows) {
                if (w.isKeyWindow) {
                    window = w;
                    break;
                }
            }
            if (window) break;
        }
    }

    return window ? window.safeAreaInsets : UIEdgeInsetsZero;
}

/// 计算数字键盘的默认 Frame
/// @return 根据屏幕尺寸计算出的键盘 Frame
+ (CGRect)keyboardFrame {
    // 获取屏幕宽度，适配横竖屏
    CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    // 高度按照宽度的 0.32 倍计算，最终高度是两倍
    CGFloat height = ((NSUInteger)(width * 0.32)) * 2;
    
    // 加上底部安全区域（刘海屏适配）
    CGFloat safeAreaBottom = [ZHHNumberKeyboardHelper safeAreaInsets].bottom;
    
    return CGRectMake(0, 0, width, height + safeAreaBottom);
}

/// 生成纯色 UIImage
/// @param color 需要生成图片的颜色
/// @param size 图片的尺寸
/// @return 生成的 UIImage
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    // 参数检查，避免创建无效图片
    if (!color || size.width <= 0 || size.height <= 0) {
        return nil;
    }

    // 开启图形上下文，自动适配屏幕分辨率
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 设置填充颜色
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    // 绘制矩形填充颜色
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    // 生成 UIImage
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}

/// 获取键盘删除按钮图标（使用系统 SF Symbols）
/// @return 删除按钮的 UIImage
+ (UIImage *)deleteIcon {
    // 使用系统 SF Symbols 图标（iOS 13.0+）
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightMedium scale:UIImageSymbolScaleMedium];
    UIImage *image = [UIImage systemImageNamed:@"delete.backward" withConfiguration:config];
    
    // 设置为黑色（适配深色/浅色模式）
    image = [image imageWithTintColor:[UIColor blackColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return image;
}

/// 获取输入视图 (UITextInput) 中当前选中的文本范围
/// @param inputView 符合 UITextInput 协议的输入控件（如 UITextView、UITextField）
/// @return 当前选中的文本范围，返回 NSRange 结构体
+ (NSRange)selectedRangeInInputView:(id<UITextInput>)inputView {
    // 获取文本的起始位置
    UITextPosition *beginning = inputView.beginningOfDocument;
    
    // 获取当前选中的文本范围
    UITextRange *selectedRange = inputView.selectedTextRange;
    
    // 获取选中文本的起始位置和结束位置
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    // 计算选中文本的起始位置（距离文本开头的偏移量）
    const NSInteger location = [inputView offsetFromPosition:beginning toPosition:selectionStart];
    
    // 计算选中文本的长度（起始位置到结束位置的偏移量）
    const NSInteger length = [inputView offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

/// 播放系统默认的输入点击音效（通常用于键盘点击）
+ (void)playClickAudio {
    [[UIDevice currentDevice] playInputClick];
}
@end
