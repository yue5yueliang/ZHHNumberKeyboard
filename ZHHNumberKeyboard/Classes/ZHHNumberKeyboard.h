//
//  ZHHNumberKeyboard.h
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2022/5/11.
//  Copyright © 2022 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZHHNumberKeyboardType) {
    /// 展示小数点（用于金额、浮点数等输入）
    ZHHNumberKeyboardTypeDecimal,
    /// 展示 "X"（用于身份证输入）
    ZHHNumberKeyboardTypeIDCard
};

@class ZHHNumberKeyboard;

/// 数字键盘的代理协议，提供可选的回调方法
@protocol ZHHNumberKeyboardDelegate <NSObject>

@optional
/// 当用户点击“完成”按钮时触发此方法
/// @param keyboard 触发事件的数字键盘实例
- (void)numberKeyboardDidTapDone:(ZHHNumberKeyboard *)keyboard;

@end

@interface ZHHNumberKeyboard : UIView

/// 确定按钮的颜色（默认蓝色）
/// 可自定义键盘“确定”按钮的颜色，例如修改为主题色。
@property (nonatomic, strong) UIColor *tintColor;

/// 键盘类型（默认 `ZHHNumberKeyboardTypeDecimal`）
/// 可设置不同类型的数字键盘，例如整数键盘、小数键盘等。
@property (nonatomic, assign) ZHHNumberKeyboardType keyboardType;

/// 监听键盘输入内容变化
/// @param currentText 当前输入框中的文本内容
/// 该方法在输入框内容发生变化时被调用，
/// 可用于实时更新 UI 或限制输入。
- (void)keyboardInputDidChange:(NSString *)currentText;

/// 完成按钮点击回调
/// 代理方法，监听用户点击键盘“完成”按钮的事件。
@property (nonatomic, weak) id<ZHHNumberKeyboardDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
