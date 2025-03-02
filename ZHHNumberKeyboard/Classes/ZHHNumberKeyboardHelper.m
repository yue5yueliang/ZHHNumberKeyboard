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

    if (@available(iOS 15.0, *)) {
        // ✅ iOS 15+ 通过 `UIWindowScene.windows` 获取当前 `keyWindow`
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
            }
            if (window) break;
        }
    } else {
        // ✅ iOS 13 - iOS 14 使用 `UIWindowScene.windows`
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
    return CGRectMake(0, 0, width, height+[ZHHNumberKeyboardHelper safeAreaInsets].bottom);
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

/// 生成键盘删除按钮图标
/// @return 绘制的删除按钮 UIImage
+ (UIImage *)deleteIcon {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake(27 * scale, 20 * scale);
    const CGFloat lineWidth = 1.1f * scale; // 这里加粗线条
    UIGraphicsBeginImageContext(size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setStroke];
    
    CGContextBeginPath(ctx);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(8.5 * scale, 19.5 * scale)];
    [bezierPath addCurveToPoint: CGPointMake(23.15 * scale, 19.5 * scale) controlPoint1: CGPointMake(11.02 * scale, 19.5 * scale) controlPoint2: CGPointMake(20.63 * scale, 19.5 * scale)];
    [bezierPath addCurveToPoint: CGPointMake(26.5 * scale, 15.5 * scale) controlPoint1: CGPointMake(25.66 * scale, 19.5 * scale) controlPoint2: CGPointMake(26.5 * scale, 17.5 * scale)];
    [bezierPath addCurveToPoint: CGPointMake(26.5 * scale, 4.5 * scale) controlPoint1: CGPointMake(26.5 * scale, 13.5 * scale) controlPoint2: CGPointMake(26.5 * scale, 7.5 * scale)];
    [bezierPath addCurveToPoint: CGPointMake(23.15 * scale, 0.5 * scale) controlPoint1: CGPointMake(26.5 * scale, 1.5 * scale) controlPoint2: CGPointMake(24.82 * scale, 0.5 * scale)];
    [bezierPath addCurveToPoint: CGPointMake(8.5 * scale, 0.5 * scale) controlPoint1: CGPointMake(21.47 * scale, 0.5 * scale) controlPoint2: CGPointMake(11.02 * scale, 0.5 * scale)];
    [bezierPath addCurveToPoint: CGPointMake(0.5 * scale, 9.5 * scale) controlPoint1: CGPointMake(5.98 * scale, 0.5 * scale) controlPoint2: CGPointMake(0.5 * scale, 9.5 * scale)];
    [bezierPath addCurveToPoint: CGPointMake(8.5 * scale, 19.5 * scale) controlPoint1: CGPointMake(0.5 * scale, 9.5 * scale) controlPoint2: CGPointMake(5.98 * scale, 19.5 * scale)];
    [bezierPath closePath];
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [UIColor.blackColor setStroke];
    bezierPath.lineWidth = lineWidth; // 加粗
    [bezierPath stroke];
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(19.5 * scale, 6.5 * scale)];
    [bezier2Path addLineToPoint: CGPointMake(12.5 * scale, 13.5 * scale)];
    bezier2Path.lineCapStyle = kCGLineCapRound;
    bezier2Path.lineJoinStyle = kCGLineJoinRound;
    
    [UIColor.blackColor setStroke];
    bezier2Path.lineWidth = lineWidth; // 加粗
    [bezier2Path stroke];
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(19.5 * scale, 13.5 * scale)];
    [bezier3Path addLineToPoint: CGPointMake(12.5 * scale, 6.5 * scale)];
    bezier3Path.lineCapStyle = kCGLineCapRound;
    
    [UIColor.blackColor setStroke];
    bezier3Path.lineWidth = lineWidth; // 加粗
    [bezier3Path stroke];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
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
