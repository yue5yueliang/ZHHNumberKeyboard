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

#pragma mark - 颜色常量定义

/// 键盘背景色 - #F5F5F5 (96% 白色)，与系统键盘一致
static UIColor *kKeyboardBackgroundColor;

/// 普通按钮背景色 - #FFFFFF (纯白色)
static UIColor *kButtonBackgroundColor;

/// 普通按钮高亮色 - #F0F0F0 (94% 白色)
static UIColor *kButtonHighlightColor;

/// 确定按钮默认背景色（鲜绿色）- 类似微信
static UIColor *kDoneButtonBackgroundColor;

/// 按钮文字颜色（黑色）
static UIColor *kButtonTextColor;

/// 确定按钮文字颜色（白色）
static UIColor *kDoneButtonTextColor;

/// 顶部分割线颜色（系统标准灰）
static UIColor *kSeparatorColor;


@interface ZHHNumberKeyboard () <UIInputViewAudioFeedback>

/// 长按删除定时器（使用 CADisplayLink 替代 NSTimer，避免循环引用）
@property (nonatomic, strong) CADisplayLink *deleteDisplayLink;

/// 绑定的第一响应者（当前正在输入的 UITextField 或 UITextView）
@property (nonatomic, weak) UIView<UIKeyInput> *firstResponder;

/// 所有按钮的数组集合（包含 0-9 数字键、小数点/X键、删除键、确定键）
@property (nonatomic, strong) NSMutableArray<ZHHNumberKeyboardButton *> *buttons;

/// 触觉反馈生成器（用于产生震动反馈）
@property (nonatomic, strong) UIImpactFeedbackGenerator *impactFeedbackGenerator;

/// 顶部分割线视图
@property (nonatomic, strong) UIView *topSeparatorView;

@end

@implementation ZHHNumberKeyboard

#pragma mark - 类初始化

/// 在类加载时初始化颜色常量
+ (void)initialize {
    if (self == [ZHHNumberKeyboard class]) {
        kKeyboardBackgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0]; // #F5F5F5 (245)
        kButtonBackgroundColor = [UIColor whiteColor]; // #FFFFFF (255)
        kButtonHighlightColor = [UIColor colorWithWhite:0.94 alpha:1.0]; // #F0F0F0 (240)
        kDoneButtonBackgroundColor = [UIColor colorWithRed:6.0/255.0 green:193.0/255.0 blue:96.0/255.0 alpha:1.0];
        kButtonTextColor = [UIColor blackColor];
        kDoneButtonTextColor = [UIColor whiteColor];
        kSeparatorColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1.0];
    }
}

#pragma mark - Lifecycle

/// 初始化方法
/// 创建键盘视图并设置默认配置
- (instancetype)init {
    // 获取适配屏幕的键盘尺寸
    CGRect rect = [ZHHNumberKeyboardHelper keyboardFrame];
    
    if (self = [super initWithFrame:rect]) {
        // 设置默认键盘类型为小数点键盘
        _keyboardType = ZHHNumberKeyboardTypeDecimal;
        
        // 设置确定按钮的默认颜色
        _tintColor = kDoneButtonBackgroundColor;
        
        // 设置键盘背景色
        self.backgroundColor = kKeyboardBackgroundColor;
        
        // 默认开启声音和触觉反馈
        _enableClickSound = YES;
        _enableHapticFeedback = YES;
        
        // 默认显示顶部分割线
        _showTopSeparator = YES;
        _topSeparatorColor = kSeparatorColor;
        
        // 初始化触觉反馈生成器（Light 级别的震动强度）
        _impactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [_impactFeedbackGenerator prepare]; // 预热，提高首次触发响应速度
        
        // 初始化 UI 组件
        [self _initUI];
        [self _initTopSeparator];
    }
    
    return self;
}

/// 安全区域变化时的回调
/// 主要用于适配刘海屏等设备的底部安全区域
- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    [self setNeedsLayout]; // 触发重新布局以适配新的安全区域
}

/// 析构方法
/// 清理定时器，防止内存泄漏
- (void)dealloc {
    [self _cleanDisplayLink];
    NSLog(@"***> %s", __func__);
}

#pragma mark - Setter Methods

/// 设置确定按钮的颜色
/// 会自动更新按钮的背景色和高亮色
- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self _updateKeyboardLayout]; // 更新确定按钮的颜色
}

/// 设置键盘类型
/// 会自动更新小数点/X 按钮的显示文本
- (void)setKeyboardType:(ZHHNumberKeyboardType)keyboardType {
    _keyboardType = keyboardType;
    [self _updateKeyboardLayout]; // 更新按钮文本
}

/// 设置是否显示顶部分割线
- (void)setShowTopSeparator:(BOOL)showTopSeparator {
    _showTopSeparator = showTopSeparator;
    self.topSeparatorView.hidden = !showTopSeparator; // 控制分割线的显示/隐藏
}

/// 设置顶部分割线的颜色
- (void)setTopSeparatorColor:(UIColor *)topSeparatorColor {
    _topSeparatorColor = topSeparatorColor;
    self.topSeparatorView.backgroundColor = topSeparatorColor; // 实时更新颜色
}

#pragma mark - Public Methods

/// 监听键盘输入内容变化
/// 根据输入内容更新确定按钮的可用状态
/// @param currentText 当前输入框中的文本内容
- (void)keyboardInputDidChange:(NSString *)currentText {
    [self updateDoneButtonState:currentText.length > 0];
}

#pragma mark - UI Initialization

/// 初始化顶部分割线
/// 创建一个细线视图，位于键盘顶部
- (void)_initTopSeparator {
    self.topSeparatorView = [[UIView alloc] init];
    self.topSeparatorView.backgroundColor = self.topSeparatorColor;
    self.topSeparatorView.hidden = !self.showTopSeparator;
    [self addSubview:self.topSeparatorView];
}

/// 初始化键盘 UI
/// 创建所有按键（0-9、小数点/X、删除、确定）并配置样式
- (void)_initUI {
    self.buttons = [NSMutableArray array];
    
    // 创建 14 个按钮：0-9 共 10 个数字键 + 小数点/X键 + 删除键 + 确定键 + 占位按钮
    for (int i = 0; i < 14; ++i) {
        ZHHNumberKeyboardButton *item = [ZHHNumberKeyboardButton buttonWithType:UIButtonTypeCustom];
        item.layer.cornerRadius = 5;
        item.layer.masksToBounds = YES;
        
        // 根据索引配置不同按钮的功能和样式
        if (i == 10) {
            // 小数点/X 按钮（第 11 个按钮，索引 10）
            item.tag = 46; // ASCII 码的 '.'
            if (self.keyboardType == ZHHNumberKeyboardTypeDecimal) {
                [item setTitle:@"." forState:UIControlStateNormal];
            } else if (self.keyboardType == ZHHNumberKeyboardTypeIDCard) {
                [item setTitle:@"X" forState:UIControlStateNormal];
            }
        } else if (i == 11) {
            // 删除键（第 12 个按钮，索引 11）
            item.tag = 127; // ASCII 码的 DEL
            UIImage *deleteIcon = [ZHHNumberKeyboardHelper deleteIcon];
            [item setImage:deleteIcon forState:UIControlStateNormal];

            // 添加长按手势以支持连续删除
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteItemLongPress:)];
            longPressGesture.minimumPressDuration = 0.3; // 设置为 0.3 秒，更快识别长按（默认 0.5 秒）
            [item addGestureRecognizer:longPressGesture];
        } else if (i == 12) {
            // 确定按钮（第 13 个按钮，索引 12）
            item.tag = -2; // 自定义负数标识
            [item setTitle:@"确定" forState:UIControlStateNormal];
            item.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:22];
        } else {
            // 数字键 0-9（索引 0-9 和 13）
            // 索引 0-9 对应数字 1-9 和 0，索引 13 暂不使用
            if (i < 9) {
                // 1-9 按钮（索引 0-8）
                item.tag = 49 + i; // ASCII 码 '1' = 49
                [item setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
            } else {
                // 0 按钮（索引 9）
                item.tag = 48; // ASCII 码 '0' = 48
                [item setTitle:@"0" forState:UIControlStateNormal];
            }
        }
        
        // 设置按钮的颜色和字体
        if (item.tag != -2) {
            // 普通按钮（数字、小数点、删除）
            [item setBackgroundColor:kButtonBackgroundColor forState:UIControlStateNormal];
            [item setBackgroundColor:kButtonHighlightColor forState:UIControlStateHighlighted]; // 备用高亮色
            [item setTitleColor:kButtonTextColor forState:UIControlStateNormal];
            [item.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:22]];
        } else {
            // 确定按钮（特殊样式）
            // 根据 tintColor 生成协调的高亮颜色
            UIColor *highlightColor = [ZHHNumberKeyboardHelper darkenColor:self.tintColor byAmount:0.1];

            [item setBackgroundColor:self.tintColor forState:UIControlStateNormal];
            [item setBackgroundColor:highlightColor forState:UIControlStateHighlighted];
            [item setTitleColor:kDoneButtonTextColor forState:UIControlStateNormal];
        }
        
        // 添加到按钮数组并设置点击事件
        [self.buttons addObject:item];
        [item addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:item];
    }
}

#pragma mark - Layout

/// 布局子视图
/// 计算并设置所有按钮和分割线的位置
/// 键盘布局：
/// ┌───────────────────────────┐
/// │ 1  2  3  DEL              │
/// │ 4  5  6  ┌──────────────┐ │
/// │ 7  8  9  │              │ │
/// │ 0     .  │    确 定      │ │
/// └─────────┴──────────────┴─┘
- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat totalWidth = CGRectGetWidth(self.bounds);
    CGFloat totalHeight = CGRectGetHeight(self.bounds) - self.safeAreaInsets.bottom;

    // 1. 顶部分割线布局
    CGFloat separatorHeight = 0.5; // 系统标准分割线高度
    self.topSeparatorView.frame = CGRectMake(0, 0, totalWidth, separatorHeight);

    // 2. 计算按键布局参数
    CGFloat margin = 10.f;        // 左右边距
    CGFloat spacing = 10.f;       // 按键间距
    CGFloat topMargin = 10.f;     // 第一排距离顶部的间距
    CGFloat keyWidth = (totalWidth - 2 * margin - 3 * spacing) / 4.f;   // 每列 4 个按钮
    CGFloat keyHeight = (totalHeight - 3 * spacing - topMargin) / 4.f;  // 每行 4 个按钮

    // 3. 布局数字键 1~9（3x3 网格）
    for (NSInteger i = 0; i < 9; i++) {
        NSInteger row = i / 3;  // 行号（0-2）
        NSInteger col = i % 3;  // 列号（0-2）
        CGFloat x = margin + col * (keyWidth + spacing);
        CGFloat y = topMargin + row * (keyHeight + spacing);
        [[self viewWithTag:49 + i] setFrame:CGRectMake(x, y, keyWidth, keyHeight)];
    }

    // 4. 布局 "0" 按钮（横跨 2 列）
    [[self viewWithTag:48] setFrame:CGRectMake(margin, 
                                               topMargin + 3 * (keyHeight + spacing), 
                                               keyWidth * 2 + spacing, 
                                               keyHeight)];

    // 5. 布局小数点/X 按钮（第 4 行第 3 列）
    [[self viewWithTag:46] setFrame:CGRectMake(margin + 2 * (keyWidth + spacing), 
                                               topMargin + 3 * (keyHeight + spacing), 
                                               keyWidth, 
                                               keyHeight)];

    // 6. 布局删除键（第 1 行第 4 列）
    [[self viewWithTag:127] setFrame:CGRectMake(margin + 3 * (keyWidth + spacing), 
                                                topMargin, 
                                                keyWidth, 
                                                keyHeight)];

    // 7. 布局确定按钮（纵跨 3 行，第 2-4 行第 4 列）
    [[self viewWithTag:-2] setFrame:CGRectMake(margin + 3 * (keyWidth + spacing), 
                                               topMargin + keyHeight + spacing, 
                                               keyWidth, 
                                               3 * keyHeight + 2 * spacing)];
}

#pragma mark - Update Methods

/// 更新键盘布局
/// 当 tintColor 或 keyboardType 改变时调用
- (void)_updateKeyboardLayout {
    for (ZHHNumberKeyboardButton *button in self.buttons) {
        if (button.tag == 46) {
            // 更新小数点/X 按钮的文本
            if (self.keyboardType == ZHHNumberKeyboardTypeDecimal) {
                [button setTitle:@"." forState:UIControlStateNormal];
            } else if (self.keyboardType == ZHHNumberKeyboardTypeIDCard) {
                [button setTitle:@"X" forState:UIControlStateNormal];
            }
        } else if (button.tag == -2) {
            // 更新确定按钮的颜色（正常色和高亮色）
            UIColor *highlightColor = [ZHHNumberKeyboardHelper darkenColor:self.tintColor byAmount:0.1];
            
            [button setBackgroundColor:self.tintColor forState:UIControlStateNormal];
            [button setBackgroundColor:highlightColor forState:UIControlStateHighlighted];
        }
    }
}

/// 更新确定按钮的可用状态
/// @param hasInput 是否有输入内容
- (void)updateDoneButtonState:(BOOL)hasInput {
    for (ZHHNumberKeyboardButton *button in self.buttons) {
        if (button.tag == -2) { // 确定按钮
            button.enabled = hasInput;
            button.alpha = hasInput ? 1.0 : 0.7; // 有内容时不透明，无内容时半透明
        }
    }
}

#pragma mark - Input Handling

/// 处理键盘输入
/// 根据按钮的 tag 值分发到不同的处理方法
/// @param tag 按钮的 tag 值
- (void)_handleInputWithKeyboardItemTag:(NSUInteger)tag {
    switch (tag) {
        case 46:  // 小数点或 X
            if (self.keyboardType == ZHHNumberKeyboardTypeDecimal) {
                [self _insertText:@"."];
            } else {
                [self _insertText:@"X"];
            }
            break;
        case 127:  // 删除键
            [self _handleDeleteButtonTap];
            break;
        case -2:  // 确定按钮
            [self _handleDoneButtonTap];
            break;
        case 48 ... 57:  // 数字 0-9
            [self _handleNumberButtonTap:(int)tag - 48];
            break;
        default:
            break;
    }
}

/// 插入文本到第一响应者
/// 会先调用 delegate 方法进行验证，通过后才插入
/// @param text 要插入的文本
- (void)_insertText:(NSString *)text {
    if ([self.firstResponder isKindOfClass:[UITextField class]]) {
        // 处理 UITextField
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
        // 处理 UITextView
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
        // 其他实现了 UIKeyInput 协议的控件
        [self.firstResponder insertText:text];
    }
}

/// 处理删除键点击
/// 删除光标前的一个字符
- (void)_handleDeleteButtonTap {
    if ([self.firstResponder hasText]) {
        [self.firstResponder deleteBackward];
    }
}

/// 处理确定按钮点击
/// 收起键盘并调用代理方法
- (void)_handleDoneButtonTap {
    [self.firstResponder resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(numberKeyboardDidTapDone:)]) {
        [self.delegate numberKeyboardDidTapDone:self];
    }
}

/// 处理数字按钮点击
/// @param decimal 数字值 (0-9)
- (void)_handleNumberButtonTap:(int)decimal {
    [self _insertText:[NSString stringWithFormat:@"%d", decimal]];
}

#pragma mark - Long Press Delete

/// 处理删除键的长按手势
/// 长按时启动定时器，实现连续快速删除
/// @param longPress 长按手势识别器
- (void)deleteItemLongPress:(UILongPressGestureRecognizer *)longPress {
    UIButton *deleteButton = (UIButton *)[self viewWithTag:127];
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        // 长按开始：取消所有 Touch 事件，防止与点击冲突
        [deleteButton cancelTrackingWithEvent:nil];
        
        // 显示高亮状态
        deleteButton.highlighted = YES;

        // 立即执行第一次删除（带反馈）
        if ([self.firstResponder hasText]) {
            if (self.enableClickSound) {
                [ZHHNumberKeyboardHelper playClickAudio];
            }
            if (self.enableHapticFeedback) {
                [self _triggerHapticFeedback];
            }
            [self _handleDeleteButtonTap];
        }

        // 启动定时删除（使用 CADisplayLink 而非 NSTimer 避免循环引用）
        self.deleteDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_repeatLongPressDelete)];
        [self.deleteDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.deleteDisplayLink.preferredFramesPerSecond = 10; // 每秒删除 10 次（约 0.1 秒一次）
    } else if (longPress.state == UIGestureRecognizerStateEnded
               || longPress.state == UIGestureRecognizerStateCancelled
               || longPress.state == UIGestureRecognizerStateFailed) {
        // 长按结束：取消高亮并停止定时器
        deleteButton.highlighted = NO;
        [self _cleanDisplayLink];
    }
}

/// 持续删除（定时器回调）
/// 直接调用删除方法并触发反馈，避免模拟点击事件导致高亮闪烁
/// 注意：只停止定时器，不取消高亮状态（用户手指可能还在按钮上）
- (void)_repeatLongPressDelete {
    // 检查是否还有内容可以删除
    if ([self.firstResponder hasText]) {
        // 播放按键音效（如果启用）
        if (self.enableClickSound) {
            [ZHHNumberKeyboardHelper playClickAudio];
        }
        
        // 触发触觉反馈（如果启用）
        if (self.enableHapticFeedback) {
            [self _triggerHapticFeedback];
        }
        
        // 执行删除操作
        [self _handleDeleteButtonTap];
    } else {
        // 内容已清空，只停止定时器（保持高亮状态，等待用户松手）
        [self _cleanDisplayLink];
    }
}

#pragma mark - Button Actions

/// 按钮点击事件统一入口
/// 处理声音、触觉反馈，并分发到具体的输入处理方法
/// @param sender 被点击的按钮
- (void)buttonTouchUpInside:(ZHHNumberKeyboardButton *)sender {
    // 获取或更新第一响应者
    if (!self.firstResponder || ![self.firstResponder isFirstResponder]) {
        self.firstResponder = (UIView<UIKeyInput> *)[UIView zhh_firstResponder];
        if (!self.firstResponder) return;
        if (![self.firstResponder conformsToProtocol:@protocol(UIKeyInput)]) return;
    }

    // 播放按键音效（如果启用）
    if (self.enableClickSound) {
        [ZHHNumberKeyboardHelper playClickAudio];
    }
    
    // 触发触觉反馈（如果启用）
    if (self.enableHapticFeedback) {
        [self _triggerHapticFeedback];
    }
    
    // 处理按键输入
    [self _handleInputWithKeyboardItemTag:sender.tag];
}

#pragma mark - UIInputViewAudioFeedback

/// 启用输入点击音效
/// 实现此协议方法后，playInputClick 才会生效
- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

#pragma mark - Private Methods

/// 触发触觉反馈
/// 产生轻微震动，并为下次反馈做准备
- (void)_triggerHapticFeedback {
    [self.impactFeedbackGenerator impactOccurred];
    [self.impactFeedbackGenerator prepare]; // 预热下一次反馈，提高响应速度
}

/// 清除 CADisplayLink 定时器
/// 防止内存泄漏
- (void)_cleanDisplayLink {
    [self.deleteDisplayLink invalidate];
    self.deleteDisplayLink = nil;
    NSLog(@"***> %s", __func__);
}

@end
