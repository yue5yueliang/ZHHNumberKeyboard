#
# Be sure to run `pod lib lint ZHHNumberKeyboard.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZHHNumberKeyboard'
  s.version          = '1.0.0'
  s.summary          = '模仿微信的 iOS 数字键盘，支持小数点/身份证键盘、声音触觉反馈、高度自定义。'

  # 详细描述 pod 的功能、用途及特点
  s.description      = <<-DESC
ZHHNumberKeyboard 是一个功能完善的 **自定义数字键盘**，完美模仿微信键盘风格，适用于 iOS 应用中的数值输入场景。

### **主要特性**
- ⌨️ **两种键盘类型**：小数点键盘（金额输入）、身份证键盘（X 键）
- 🎨 **高度自定义**：自定义确定按钮颜色、顶部分割线、按钮样式
- 🔊 **反馈支持**：按键声音反馈、触觉震动反馈（可独立开关）
- 🎯 **智能状态管理**：确定按钮根据输入自动启用/禁用
- ⚡️ **长按快速删除**：长按删除键快速清除内容
- 📱 **完美适配**：自动适配全面屏（iPhone X 及以上）安全区域
- 🔌 **简单集成**：一行代码替换 UITextField/UITextView 键盘

### **适用场景**

- 💰 支付输入（金额、支付密码）

- 📝 表单填写（身份证号、手机号、邮编）

- 🔢 验证码输入（6 位、4 位数字）

- 📊 数据录入（数值型数据快速录入）
  DESC

  s.homepage         = 'https://github.com/yue5yueliang/ZHHNumberKeyboard'
  s.screenshots      = 'https://raw.githubusercontent.com/yue5yueliang/ZHHNumberKeyboard/main/screenshots/example_decimal.png', 'https://raw.githubusercontent.com/yue5yueliang/ZHHNumberKeyboard/main/screenshots/example_idcard.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '桃色三岁' => '136769890@qq.com' }
  s.source           = { :git => 'https://github.com/yue5yueliang/ZHHNumberKeyboard.git', :tag => s.version.to_s }

  s.social_media_url = 'https://github.com/yue5yueliang'
  s.ios.deployment_target = '13.0'
  
  # Swift 版本配置
  s.swift_versions   = ['5.0']
  s.requires_arc     = true

  # 源文件路径，指明需要包含的源代码文件（Swift 文件）
  s.source_files = 'ZHHNumberKeyboard/Classes/**/*.swift'

  # 如果需要包含资源文件，可以通过下面的代码添加
  # s.resource_bundles = {
  #   'ZHHNumberKeyboard' => ['ZHHNumberKeyboard/Assets/*.png']
  # }

  # 如果库依赖其他框架，可以在这里声明依赖
  s.frameworks = 'UIKit', 'Foundation'

  # 如果库依赖其他第三方 pod，可以通过 s.dependency 来声明
  # s.dependency 'AFNetworking', '~> 2.3'
end
