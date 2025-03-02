//
//  ZHHNumberKeyboard.m
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2022/5/11.
//  Copyright © 2022 桃色三岁. All rights reserved.
//

#import "ZHHNumberKeyboard.h"
#import "ZHHNumberKeyboardButton.h"
#import "ZHHNumberKeyboardHelper.h"
#import "UIView+ZHHFindFirstResponder.h"


@interface ZHHNumberKeyboard () <UIInputViewAudioFeedback>

// 使用 CADisplayLink 替代 NSTimer，避免手动管理生命周期
@property (nonatomic, strong) CADisplayLink *deleteDisplayLink;
/// 绑定的第一响应者（UITextField 或 UITextView）
@property (nonatomic, weak) UIView<UIKeyInput> *firstResponder;
@property (nonatomic, strong) NSMutableArray<ZHHNumberKeyboardButton *> *buttons;

@end

@implementation ZHHNumberKeyboard

#pragma mark - init

- (instancetype)init {
    CGRect rect = [ZHHNumberKeyboardHelper keyboardFrame];
    
    if (self = [super initWithFrame:rect]) {
        _keyboardType = ZHHNumberKeyboardTypeDecimal; // 默认小数点键盘
        _tintColor = [UIColor colorWithRed:6 / 255.f green:193 / 255.f blue:96 / 255.f alpha:1]; // 默认鲜绿色
        self.backgroundColor = [UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1];
        
        // 适配安全区域
        rect.size.height += [self safeAreaInsets].bottom;
        self.frame = rect;
        
        [self _initUI];
    }
    
    return self;
}

/// 适配安全区域（在 `safeAreaInsetsDidChange` 里更新）
- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    [self _adjustForSafeArea];
    [self setNeedsLayout]; // 触发重新布局
}

/// 更新键盘高度，适配安全区域
- (void)_adjustForSafeArea {
    if (@available(iOS 11.0, *)) {
        CGRect rect = self.frame;
        rect.size.height = [ZHHNumberKeyboardHelper keyboardFrame].size.height + self.safeAreaInsets.bottom;
        self.frame = rect;
    }
}

#pragma mark - Setter 方法

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self _updateKeyboardLayout];
}

- (void)setKeyboardType:(ZHHNumberKeyboardType)keyboardType {
    _keyboardType = keyboardType;
    [self _updateKeyboardLayout];
}

#pragma mark - 更新键盘布局

- (void)_updateKeyboardLayout {
    for (ZHHNumberKeyboardButton *button in self.buttons) {
        if (button.tag == 46) { // 只修改小数点/X 按钮
            if (self.keyboardType == ZHHNumberKeyboardTypeDecimal) {
                [button setTitle:@"." forState:UIControlStateNormal];
            } else if (self.keyboardType == ZHHNumberKeyboardTypeIDCard) {
                [button setTitle:@"X" forState:UIControlStateNormal];
            }
        } else if (button.tag == -2) { // 确定按钮
            [button setBackgroundColor:self.tintColor forState:UIControlStateNormal];
        }
    }
}

- (void)keyboardInputDidChange:(NSString *)currentText {
    [self updateDoneButtonState:currentText.length > 0];
}

- (void)updateDoneButtonState:(BOOL)hasInput {
    for (ZHHNumberKeyboardButton *button in self.buttons) {
        if (button.tag == -2) { // 确定按钮
            button.enabled = hasInput;
            button.alpha = hasInput ? 1.0 : 0.7; // 透明度控制可用/不可用状态
        }
    }
}

/// 初始化 UI
- (void)_initUI {
    self.buttons = [NSMutableArray array]; // 确保初始化
    /// 创建 14 个键盘按钮
    for (int i = 0; i < 14; ++i) {
        ZHHNumberKeyboardButton *item = [ZHHNumberKeyboardButton buttonWithType:UIButtonTypeCustom];
        item.layer.cornerRadius = 5;
        item.layer.masksToBounds = YES;
        if (i == 10) {
            item.tag = 46;
            if (self.keyboardType == ZHHNumberKeyboardTypeDecimal) {
                [item setTitle:@"." forState:UIControlStateNormal];
            } else if (self.keyboardType == ZHHNumberKeyboardTypeIDCard) {
                [item setTitle:@"X" forState:UIControlStateNormal];
            }
        } else if (i == 11) {
            item.tag = 127;
            UIImage *deleteIcon = [ZHHNumberKeyboardHelper deleteIcon];
            [item setImage:deleteIcon forState:UIControlStateNormal];

            // 长按删除按钮的手势
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteItemLongPress:)];
            [item addGestureRecognizer:longPressGesture];
        } else if (i == 12) {
            item.tag = -2;
            [item setTitle:@"确定" forState:UIControlStateNormal];
            item.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:22];
        } else {
            item.tag = 48 + i;
            [item setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        }
        
        if (item.tag != -2) {
            [item setBackgroundColor:[UIColor colorWithRed:255 / 255.f green:255 / 255.f blue:255 / 255.f alpha:1] forState:UIControlStateNormal];
            [item setBackgroundColor:[UIColor colorWithRed:230 / 255.f green:230 / 255.f blue:230 / 255.f alpha:1] forState:UIControlStateHighlighted];
            [item setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [item.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:22]];
        } else {
            CGFloat h, s, b, a;
            [self.tintColor getHue:&h saturation:&s brightness:&b alpha:&a];
            UIColor *highlightColor = [UIColor colorWithHue:h saturation:s brightness:b - .1f alpha:a];

            [item setBackgroundColor:self.tintColor forState:UIControlStateNormal];
            [item setBackgroundColor:highlightColor forState:UIControlStateHighlighted];
            [item setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        [self.buttons addObject:item];
        [item addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:item];
    }
}

/// 处理键盘输入
- (void)_handleInputWithKeyboardItemTag:(NSUInteger)tag {
    switch (tag) {
        case 46:
            if (self.keyboardType == ZHHNumberKeyboardTypeDecimal) {
                [self _insertText:@"."];
            }else{
                [self _insertText:@"X"];
            }
            break;
        case 127:
            [self _handleDeleteButtonTap];
            break;
        case -2:
            [self _handleDoneButtonTap];
            break;
        case 48 ... 57: // 0 ~ 9
            [self _handleNumberButtonTap:(int)tag - 48];
            break;
        default:
            break;
    }
}

/// 插入文本到第一响应者
- (void)_insertText:(NSString *)text {
    if ([self.firstResponder isKindOfClass:[UITextField class]]) {
        id<UITextFieldDelegate> delegate = [(UITextField *)self.firstResponder delegate];
        if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            NSRange range = [ZHHNumberKeyboardHelper selectedRangeInInputView:(id<UITextInput>)self.firstResponder];
            if ([delegate textField:(UITextField *)self.firstResponder shouldChangeCharactersInRange:range replacementString:text]) {
                [self.firstResponder insertText:text];
            }
        } else {
            [self.firstResponder insertText:text];
        }
    } else if ([self.firstResponder isKindOfClass:[UITextView class]]) {
        id<UITextViewDelegate> delegate = [(UITextView *)self.firstResponder delegate];
        if ([delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            NSRange range = [ZHHNumberKeyboardHelper selectedRangeInInputView:(id<UITextInput>)self.firstResponder];
            if ([delegate textView:(UITextView *)self.firstResponder shouldChangeTextInRange:range replacementText:text]) {
                [self.firstResponder insertText:text];
            }
        } else {
            [self.firstResponder insertText:text];
        }
    } else {
        [self.firstResponder insertText:text];
    }
}

/// 处理删除键的长按事件
- (void)deleteItemLongPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ((UIButton *)[self viewWithTag:127]).highlighted = YES;
        });

        // 使用 CADisplayLink 代替 NSTimer
        self.deleteDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_repeatLongPressDelete)];
        [self.deleteDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.deleteDisplayLink.preferredFramesPerSecond = 10; // 约等于 0.1s 执行一次
    } else if (longPress.state == UIGestureRecognizerStateEnded
               || longPress.state == UIGestureRecognizerStateCancelled
               || longPress.state == UIGestureRecognizerStateFailed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ((UIButton *)[self viewWithTag:127]).highlighted = NO;
        });
        [self _cleanDisplayLink];
    }
}

/// 持续删除
- (void)_repeatLongPressDelete {
    [(UIControl *)[self viewWithTag:127] sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Action Methods

- (void)_handleDeleteButtonTap {
    if ([self.firstResponder hasText]) {
        [self.firstResponder deleteBackward];
    }
}

- (void)_handleDoneButtonTap {
    [self.firstResponder resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(numberKeyboardDidTapDone:)]) {
        [self.delegate numberKeyboardDidTapDone:self];
    }
}

- (void)_handleNumberButtonTap:(int)decimal {
    [self _insertText:[NSString stringWithFormat:@"%d", decimal]];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat totalWidth = CGRectGetWidth(self.bounds);
    CGFloat totalHeight = CGRectGetHeight(self.bounds) - self.safeAreaInsets.bottom;

    CGFloat margin = 10.f;   // 左右边距
    CGFloat spacing = 10.f;  // 按键间距
    CGFloat topMargin = 10.f; // 第一排距离顶部的间距
    CGFloat keyWidth = (totalWidth - 2 * margin - 3 * spacing) / 4.f;
    CGFloat keyHeight = (totalHeight - 3 * spacing - topMargin) / 4.f;

    // 数字键 1~9
    for (NSInteger i = 0; i < 9; i++) {
        NSInteger row = i / 3;
        NSInteger col = i % 3;
        CGFloat x = margin + col * (keyWidth + spacing);
        CGFloat y = topMargin + row * (keyHeight + spacing);
        [[self viewWithTag:49 + i] setFrame:CGRectMake(x, y, keyWidth, keyHeight)];
    }

    // "0" (tag: 48) - 占据3列
    [[self viewWithTag:48] setFrame:CGRectMake(margin, topMargin + 3 * (keyHeight + spacing), keyWidth * 2 + 1 * spacing, keyHeight)];

    // "." 或 "X" (tag: 46) - 在最右侧
    [[self viewWithTag:46] setFrame:CGRectMake(margin + 2 * (keyWidth + spacing), topMargin + 3 * (keyHeight + spacing), keyWidth, keyHeight)];

    // 删除键 (tag: 127) - 第一行右侧
    [[self viewWithTag:127] setFrame:CGRectMake(margin + 3 * (keyWidth + spacing), topMargin, keyWidth, keyHeight)];

    // 确认键 (绿色 "确定"，tag: -2) - 占据 3 行
    [[self viewWithTag:-2] setFrame:CGRectMake(margin + 3 * (keyWidth + spacing), topMargin + keyHeight + spacing, keyWidth, 3 * keyHeight + 2 * spacing)];
}

#pragma mark - Action

/// 按钮点击事件
- (void)buttonTouchUpInside:(ZHHNumberKeyboardButton *)sender {
    if (!self.firstResponder || ![self.firstResponder isFirstResponder]) {
        self.firstResponder = (UIView<UIKeyInput> *)[UIView zhh_firstResponder];
        if (!self.firstResponder) return;
        if (![self.firstResponder conformsToProtocol:@protocol(UIKeyInput)]) return;
    }

    [ZHHNumberKeyboardHelper playClickAudio];
    [self _handleInputWithKeyboardItemTag:sender.tag];
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}


#pragma mark - Private Methods

/// 清除 CADisplayLink，防止内存泄漏
- (void)_cleanDisplayLink {
    [self.deleteDisplayLink invalidate];
    self.deleteDisplayLink = nil;
    NSLog(@"***> %s", __func__);
}

- (void)dealloc {
    [self _cleanDisplayLink];
    NSLog(@"***> %s", __func__);
}
@end

