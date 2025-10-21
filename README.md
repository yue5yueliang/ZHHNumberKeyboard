# ZHHNumberKeyboard

![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)
![Objective-C](https://img.shields.io/badge/language-Objective--C-orange.svg)
![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-green.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

一个功能强大的 **自定义数字键盘**，模仿微信数字键盘风格，适用于 iOS 应用中的数值输入场景。支持外观定制、输入控制，并完美适配浅色/暗黑模式及全面屏设备。

## ✨ 特性

- 🎨 **高度可定制**：支持自定义按键颜色、样式等
- 🎯 **精准输入控制**：可配置不同的键盘类型（小数点/身份证）
- 📱 **完美适配**：支持全面屏安全区域适配
- 🎹 **优质体验**：流畅的按键响应，支持长按快速删除
- 🔊 **声音反馈**：支持系统按键音效，可自由开关
- 📳 **触觉反馈**：支持震动反馈（Haptic Feedback），可独立控制
- 🎛️ **灵活配置**：声音和触感可自由组合（只声音/只触感/声音+触感/全关闭）
- 🔌 **简单集成**：可无缝替换 `UITextField` 和 `UITextView` 的默认键盘
- 🌗 **暗黑模式**：通过自定义颜色可适配深色模式

## 📸 效果预览

| 小数点键盘 | 身份证键盘 |
|:---:|:---:|
| ![小数点键盘](https://via.placeholder.com/300x200?text=Decimal+Keyboard) | ![身份证键盘](https://via.placeholder.com/300x200?text=IDCard+Keyboard) |

## 🔧 安装

### CocoaPods

在你的 `Podfile` 中添加：

```ruby
pod 'ZHHNumberKeyboard', '~> 0.0.1'
```

然后执行：

```bash
pod install
```

### 手动集成

将 `ZHHNumberKeyboard/Classes` 文件夹下的所有文件拖入你的项目中即可。

## 📖 使用方法

### 基础使用

```objc
#import "ZHHNumberKeyboard.h"

@interface YourViewController () <ZHHNumberKeyboardDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) ZHHNumberKeyboard *numberKeyboard;
@end

@implementation YourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建数字键盘
    ZHHNumberKeyboard *numberKeyboard = [[ZHHNumberKeyboard alloc] init];
    
    // 设置键盘代理
    numberKeyboard.delegate = self;
    
    // 将自定义键盘设置为 TextField 的输入视图
    self.textField.inputView = numberKeyboard;
    
    // 监听输入变化以更新按钮状态
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // 初始化完成按钮状态
    [numberKeyboard keyboardInputDidChange:self.textField.text ?: @""];
    
    self.numberKeyboard = numberKeyboard;
}

- (void)textFieldDidChange:(UITextField *)textField {
    // 更新键盘的完成按钮状态
    [self.numberKeyboard keyboardInputDidChange:textField.text];
}

#pragma mark - ZHHNumberKeyboardDelegate

- (void)numberKeyboardDidTapDone:(ZHHNumberKeyboard *)keyboard {
    NSLog(@"用户点击了完成按钮");
    // 在这里处理完成按钮的逻辑
}

@end
```

### 配置键盘类型

```objc
// 小数点键盘（默认）
numberKeyboard.keyboardType = ZHHNumberKeyboardTypeDecimal;

// 身份证键盘（右下角显示 "X"）
numberKeyboard.keyboardType = ZHHNumberKeyboardTypeIDCard;
```

### 自定义按键颜色

```objc
// 自定义完成按钮颜色
numberKeyboard.tintColor = [UIColor systemBlueColor];

// 或使用自定义颜色
numberKeyboard.tintColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:1.0];
```

### 配置顶部分割线 ⭐️ NEW

```objc
ZHHNumberKeyboard *keyboard = [[ZHHNumberKeyboard alloc] init];

// 显示/隐藏顶部分割线（默认显示）
keyboard.showTopSeparator = YES;

// 自定义分割线颜色
keyboard.topSeparatorColor = [UIColor lightGrayColor];
```

### 配置声音和触觉反馈

键盘支持灵活的反馈配置，你可以根据需求自由组合：

```objc
ZHHNumberKeyboard *keyboard = [[ZHHNumberKeyboard alloc] init];

// 方案 1：同时启用声音和触觉反馈（默认，体验最佳）
keyboard.enableClickSound = YES;
keyboard.enableHapticFeedback = YES;

// 方案 2：只要声音，不要震动
keyboard.enableClickSound = YES;
keyboard.enableHapticFeedback = NO;

// 方案 3：只要震动，不要声音
keyboard.enableClickSound = NO;
keyboard.enableHapticFeedback = YES;

// 方案 4：静默模式，关闭所有反馈
keyboard.enableClickSound = NO;
keyboard.enableHapticFeedback = NO;
```

**说明：**
- 声音反馈使用系统键盘音效，需要设备未静音且系统设置允许键盘音
- 触觉反馈使用轻度震动（Light Impact），需要设备支持 Taptic Engine（iPhone 7 及以上）
- 两个开关可独立控制，互不影响
- 默认两者都开启，提供最佳用户体验

### 配合 UITextView 使用

```objc
UITextView *textView = [[UITextView alloc] init];
ZHHNumberKeyboard *keyboard = [[ZHHNumberKeyboard alloc] init];
textView.inputView = keyboard;
```

## 📋 API 文档

### ZHHNumberKeyboard

#### 属性

| 属性 | 类型 | 说明 | 默认值 |
|:---|:---|:---|:---|
| `keyboardType` | `ZHHNumberKeyboardType` | 键盘类型（小数点/身份证） | `ZHHNumberKeyboardTypeDecimal` |
| `tintColor` | `UIColor *` | 完成按钮的颜色 | 绿色 `RGB(6, 193, 96)` |
| `enableClickSound` | `BOOL` | 是否启用按键音效 | `YES` |
| `enableHapticFeedback` | `BOOL` | 是否启用触觉反馈（震动） | `YES` |
| `showTopSeparator` | `BOOL` | 是否显示顶部分割线 | `YES` |
| `topSeparatorColor` | `UIColor *` | 顶部分割线颜色 | 浅灰色 `RGB(0.78, 0.78, 0.8)` |
| `delegate` | `id<ZHHNumberKeyboardDelegate>` | 键盘代理 | `nil` |

#### 方法

```objc
/// 更新键盘状态（用于控制完成按钮的可用性）
/// @param currentText 当前输入框中的文本内容
- (void)keyboardInputDidChange:(NSString *)currentText;
```

### ZHHNumberKeyboardType

```objc
typedef NS_ENUM(NSUInteger, ZHHNumberKeyboardType) {
    /// 展示小数点（用于金额、浮点数等输入）
    ZHHNumberKeyboardTypeDecimal,
    /// 展示 "X"（用于身份证输入）
    ZHHNumberKeyboardTypeIDCard
};
```

### ZHHNumberKeyboardDelegate

```objc
@protocol ZHHNumberKeyboardDelegate <NSObject>

@optional
/// 当用户点击"完成"按钮时触发
/// @param keyboard 触发事件的数字键盘实例
- (void)numberKeyboardDidTapDone:(ZHHNumberKeyboard *)keyboard;

@end
```

## 💡 使用场景

- 💰 **支付输入**：金额输入、支付密码
- 📝 **表单填写**：身份证号、手机号、邮编
- 🔢 **验证码**：6 位、4 位数字验证码
- 📊 **数据录入**：数值型数据的快速录入

## 🎯 核心特性说明

### 1. 智能按钮状态管理

完成按钮会根据输入内容自动启用/禁用：
- 输入框为空时，完成按钮呈半透明不可点击状态
- 有内容时，完成按钮恢复正常可点击状态

### 2. 长按快速删除

删除键支持长按快速删除功能，提升用户体验。

### 3. 代理方法支持

完全兼容 `UITextFieldDelegate` 和 `UITextViewDelegate`，你可以在代理方法中进行输入验证：

```objc
- (BOOL)textField:(UITextField *)textField 
    shouldChangeCharactersInRange:(NSRange)range 
    replacementString:(NSString *)string {
    
    // 在这里添加你的输入验证逻辑
    return YES;
}
```

### 4. 声音和触觉反馈

键盘提供了两种反馈机制，可独立控制：

**声音反馈（enableClickSound）**
- 点击按键时播放系统键盘音效
- 与系统设置联动（静音模式下不会播放）
- 使用 `UIDevice` 的 `playInputClick` 方法
- 默认开启

**触觉反馈（enableHapticFeedback）**
- 点击按键时产生轻微震动
- 使用 `UIImpactFeedbackGenerator` 实现
- 支持 iPhone 7 及以上设备
- 震动强度：Light（轻度）
- 默认开启

**灵活组合**

你可以根据应用场景选择合适的反馈方式：
- 📱 **游戏/娱乐应用**：建议开启声音 + 触感
- 🏢 **办公/生产力应用**：建议只开启触感
- 🤫 **安静场景**：可关闭所有反馈
- ♿️ **无障碍需求**：可单独开启触感辅助用户

### 5. 顶部分割线

键盘顶部提供了一条可选的分割线，用于视觉分隔：

**功能特点**
- 默认显示，符合 iOS 键盘设计规范
- 可通过 `showTopSeparator` 属性控制显示/隐藏
- 可通过 `topSeparatorColor` 属性自定义颜色
- 分割线高度为 0.5 像素，与系统保持一致
- 自动适配键盘宽度

**使用示例**

```objc
// 隐藏分割线
keyboard.showTopSeparator = NO;

// 自定义分割线颜色（深色模式适配）
keyboard.topSeparatorColor = [UIColor darkGrayColor];
```

### 6. 安全区域适配

自动适配 iPhone X 及以上机型的底部安全区域，无需额外配置。

## ⚙️ 系统要求

- iOS 13.0+
- Xcode 11.0+
- Objective-C

## 📝 更新日志

### Version 0.0.1 (2025-03-02)

- ✅ 初始版本发布
- ✅ 支持小数点键盘和身份证键盘
- ✅ 支持自定义按键颜色
- ✅ 支持代理回调
- ✅ 完美适配全面屏设备
- ✅ 支持长按快速删除
- ✅ 支持按键音效（可开关）
- ✅ 支持触觉反馈/震动反馈（可开关）
- ✅ 声音和触感可独立控制和自由组合
- ✅ 支持顶部分割线（可显示/隐藏，可自定义颜色）
- ✅ 使用系统 SF Symbols 图标，代码更简洁

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

ZHHNumberKeyboard 使用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 👨‍💻 作者

**桃色三岁**

- Email: 136769890@qq.com
- GitHub: [@yue5yueliang](https://github.com/yue5yueliang)

## ⭐️ 如果觉得有用，请给个 Star 吧！

---

<p align="center">Made with ❤️ by 桃色三岁</p>
