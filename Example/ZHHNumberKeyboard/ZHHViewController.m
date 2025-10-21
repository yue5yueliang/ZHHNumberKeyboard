//
//  ZHHViewController.m
//  ZHHNumberKeyboard
//
//  Created by 桃色三岁 on 03/02/2025.
//  Copyright (c) 2025 桃色三岁. All rights reserved.
//

#import "ZHHViewController.h"
#import "ZHHNumberKeyboard.h"

@interface ZHHViewController () <UITextFieldDelegate, ZHHNumberKeyboardDelegate>

// 输入框
@property (nonatomic, strong) UITextField *amountTextField;      // 金额输入框（小数点键盘）
@property (nonatomic, strong) UITextField *idCardTextField;      // 身份证输入框（X键盘）
@property (nonatomic, strong) UITextField *phoneTextField;       // 手机号输入框（小数点键盘）

// 键盘
@property (nonatomic, strong) ZHHNumberKeyboard *decimalKeyboard;  // 小数点键盘
@property (nonatomic, strong) ZHHNumberKeyboard *idCardKeyboard;   // 身份证键盘

// 控制开关
@property (nonatomic, strong) UISwitch *soundSwitch;            // 声音开关
@property (nonatomic, strong) UISwitch *hapticSwitch;           // 触感开关
@property (nonatomic, strong) UISwitch *separatorSwitch;        // 分割线开关

// 当前激活的键盘
@property (nonatomic, weak) ZHHNumberKeyboard *currentKeyboard;

@end

@implementation ZHHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.97 alpha:1.0];
    self.title = @"数字键盘示例";
    
    [self setupUI];
    [self setupKeyboards];
}

#pragma mark - UI Setup

- (void)setupUI {
    CGFloat margin = 20;
    CGFloat spacing = 15;
    CGFloat yOffset = 100;
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, yOffset, self.view.bounds.size.width - 2 * margin, 30)];
    titleLabel.text = @"📱 功能演示";
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    titleLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:titleLabel];
    yOffset += 50;
    
    // ========== 金额输入框 ==========
    UILabel *amountLabel = [self createLabelWithText:@"💰 金额输入（小数点键盘）" frame:CGRectMake(margin, yOffset, 200, 20)];
    [self.view addSubview:amountLabel];
    yOffset += 25;
    
    self.amountTextField = [self createTextFieldWithPlaceholder:@"请输入金额" frame:CGRectMake(margin, yOffset, self.view.bounds.size.width - 2 * margin, 45)];
    [self.view addSubview:self.amountTextField];
    yOffset += 60;
    
    // ========== 身份证输入框 ==========
    UILabel *idCardLabel = [self createLabelWithText:@"🆔 身份证号（X键盘）" frame:CGRectMake(margin, yOffset, 200, 20)];
    [self.view addSubview:idCardLabel];
    yOffset += 25;
    
    self.idCardTextField = [self createTextFieldWithPlaceholder:@"请输入身份证号" frame:CGRectMake(margin, yOffset, self.view.bounds.size.width - 2 * margin, 45)];
    [self.view addSubview:self.idCardTextField];
    yOffset += 60;
    
    // ========== 手机号输入框 ==========
    UILabel *phoneLabel = [self createLabelWithText:@"📱 手机号（小数点键盘）" frame:CGRectMake(margin, yOffset, 200, 20)];
    [self.view addSubview:phoneLabel];
    yOffset += 25;
    
    self.phoneTextField = [self createTextFieldWithPlaceholder:@"请输入手机号" frame:CGRectMake(margin, yOffset, self.view.bounds.size.width - 2 * margin, 45)];
    [self.view addSubview:self.phoneTextField];
    yOffset += 60;
    
    // ========== 分割线 ==========
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(margin, yOffset, self.view.bounds.size.width - 2 * margin, 1)];
    separator.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [self.view addSubview:separator];
    yOffset += 20;
    
    // ========== 反馈控制 ==========
    UILabel *settingsLabel = [self createLabelWithText:@"⚙️ 反馈设置" frame:CGRectMake(margin, yOffset, 200, 20)];
    settingsLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:settingsLabel];
    yOffset += 35;
    
    // 声音开关
    UILabel *soundLabel = [self createLabelWithText:@"🔊 按键音效" frame:CGRectMake(margin, yOffset, 150, 30)];
    [self.view addSubview:soundLabel];
    
    self.soundSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - margin - 51, yOffset, 51, 31)];
    self.soundSwitch.on = YES;
    [self.soundSwitch addTarget:self action:@selector(soundSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.soundSwitch];
    yOffset += 45;
    
    // 触感开关
    UILabel *hapticLabel = [self createLabelWithText:@"📳 触觉反馈" frame:CGRectMake(margin, yOffset, 150, 30)];
    [self.view addSubview:hapticLabel];
    
    self.hapticSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - margin - 51, yOffset, 51, 31)];
    self.hapticSwitch.on = YES;
    [self.hapticSwitch addTarget:self action:@selector(hapticSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.hapticSwitch];
    yOffset += 45;
    
    // 分割线开关
    UILabel *separatorLabel = [self createLabelWithText:@"━ 顶部分割线" frame:CGRectMake(margin, yOffset, 150, 30)];
    [self.view addSubview:separatorLabel];
    
    self.separatorSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - margin - 51, yOffset, 51, 31)];
    self.separatorSwitch.on = YES;
    [self.separatorSwitch addTarget:self action:@selector(separatorSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.separatorSwitch];
    yOffset += 60;
    
    // ========== 提示信息 ==========
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, yOffset, self.view.bounds.size.width - 2 * margin, 60)];
    tipLabel.text = @"💡 提示：点击输入框即可使用自定义数字键盘\n开关可实时控制所有键盘的反馈效果";
    tipLabel.font = [UIFont systemFontOfSize:13];
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.numberOfLines = 0;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    
    // 添加点击手势收起键盘
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)setupKeyboards {
    // 创建小数点键盘
    self.decimalKeyboard = [[ZHHNumberKeyboard alloc] init];
    self.decimalKeyboard.keyboardType = ZHHNumberKeyboardTypeDecimal;
    self.decimalKeyboard.enableClickSound = YES;
    self.decimalKeyboard.enableHapticFeedback = YES;
    self.decimalKeyboard.delegate = self;
    self.decimalKeyboard.tintColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:1.0]; // 蓝色
    
    // 创建身份证键盘
    self.idCardKeyboard = [[ZHHNumberKeyboard alloc] init];
    self.idCardKeyboard.keyboardType = ZHHNumberKeyboardTypeIDCard;
    self.idCardKeyboard.enableClickSound = YES;
    self.idCardKeyboard.enableHapticFeedback = YES;
    self.idCardKeyboard.delegate = self;
    self.idCardKeyboard.tintColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.4 alpha:1.0]; // 绿色
    
    // 为输入框设置键盘
    self.amountTextField.inputView = self.decimalKeyboard;
    self.idCardTextField.inputView = self.idCardKeyboard;
    self.phoneTextField.inputView = self.decimalKeyboard;
    
    // 设置代理
    self.amountTextField.delegate = self;
    self.idCardTextField.delegate = self;
    self.phoneTextField.delegate = self;
    
    // 监听输入变化
    [self.amountTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.idCardTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // 初始化完成按钮状态
    [self.decimalKeyboard keyboardInputDidChange:@""];
    [self.idCardKeyboard keyboardInputDidChange:@""];
}

#pragma mark - Helper Methods

- (UILabel *)createLabelWithText:(NSString *)text frame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor darkGrayColor];
    return label;
}

- (UITextField *)createTextFieldWithPlaceholder:(NSString *)placeholder frame:(CGRect)frame {
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.placeholder = placeholder;
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = [UIColor whiteColor];
    textField.layer.cornerRadius = 8;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    textField.font = [UIFont systemFontOfSize:16];
    textField.textColor = [UIColor darkTextColor];
    
    // 添加左边距
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, frame.size.height)];
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    return textField;
}

#pragma mark - Switch Actions

- (void)soundSwitchChanged:(UISwitch *)sender {
    BOOL enabled = sender.isOn;
    self.decimalKeyboard.enableClickSound = enabled;
    self.idCardKeyboard.enableClickSound = enabled;
    NSLog(@"🔊 按键音效: %@", enabled ? @"开启" : @"关闭");
}

- (void)hapticSwitchChanged:(UISwitch *)sender {
    BOOL enabled = sender.isOn;
    self.decimalKeyboard.enableHapticFeedback = enabled;
    self.idCardKeyboard.enableHapticFeedback = enabled;
    NSLog(@"📳 触觉反馈: %@", enabled ? @"开启" : @"关闭");
}

- (void)separatorSwitchChanged:(UISwitch *)sender {
    BOOL enabled = sender.isOn;
    self.decimalKeyboard.showTopSeparator = enabled;
    self.idCardKeyboard.showTopSeparator = enabled;
    NSLog(@"━ 顶部分割线: %@", enabled ? @"显示" : @"隐藏");
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // 记录当前活跃的键盘
    if (textField == self.amountTextField || textField == self.phoneTextField) {
        self.currentKeyboard = self.decimalKeyboard;
    } else if (textField == self.idCardTextField) {
        self.currentKeyboard = self.idCardKeyboard;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // 针对不同输入框的验证逻辑
    if (textField == self.amountTextField) {
        // 金额输入：限制小数点后两位
        NSArray *components = [newText componentsSeparatedByString:@"."];
        if (components.count > 2) {
            return NO; // 不允许多个小数点
        }
        if (components.count == 2 && [components[1] length] > 2) {
            return NO; // 小数点后最多两位
        }
    } else if (textField == self.idCardTextField) {
        // 身份证：限制18位
        if (newText.length > 18) {
            return NO;
        }
    } else if (textField == self.phoneTextField) {
        // 手机号：限制11位，不允许小数点
        if ([string isEqualToString:@"."]) {
            return NO; // 手机号不允许小数点
        }
        if (newText.length > 11) {
            return NO;
        }
    }
    
    NSLog(@"📝 输入内容: %@", newText);
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    // 更新对应键盘的完成按钮状态
    if (textField == self.amountTextField || textField == self.phoneTextField) {
        [self.decimalKeyboard keyboardInputDidChange:textField.text];
    } else if (textField == self.idCardTextField) {
        [self.idCardKeyboard keyboardInputDidChange:textField.text];
    }
}

#pragma mark - ZHHNumberKeyboardDelegate

- (void)numberKeyboardDidTapDone:(ZHHNumberKeyboard *)keyboard {
    if (keyboard == self.decimalKeyboard) {
        NSLog(@"✅ 小数点键盘 - 完成按钮被点击");
        if ([self.amountTextField isFirstResponder]) {
            NSLog(@"   金额: %@", self.amountTextField.text);
        } else if ([self.phoneTextField isFirstResponder]) {
            NSLog(@"   手机号: %@", self.phoneTextField.text);
        }
    } else if (keyboard == self.idCardKeyboard) {
        NSLog(@"✅ 身份证键盘 - 完成按钮被点击");
        NSLog(@"   身份证号: %@", self.idCardTextField.text);
    }
    
    // 收起键盘
    [self.view endEditing:YES];
}

@end
