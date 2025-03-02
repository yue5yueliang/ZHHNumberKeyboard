Pod::Spec.new do |s|
  s.name             = 'ZHHNumberKeyboard'
  s.version          = '0.0.1'
  s.summary          = 'ZHHNumberKeyboard - 可自定义的 iOS 数字键盘，支持按键样式调整、输入控制及暗黑模式。'

  # 详细描述 pod 的功能、用途及特点
  s.description      = <<-DESC
ZHHNumberKeyboard 是一个功能强大的 **自定义数字键盘**，适用于 iOS 应用中的数值输入场景。
它可替代系统默认键盘，支持外观定制、输入控制，并适配浅色/暗黑模式，让你的应用拥有更优质的输入体验。

### **主要特性(暂不支持，后续会增加以下)**
- 🎨 **高度可定制**：支持调整按键大小、字体、颜色等
- 🎯 **精准输入控制**：可自定义输入规则，如金额输入、验证码输入等
- 🌗 **暗黑模式适配**：根据 iOS 主题自动切换浅色/深色模式
- 🎹 **手感优化**：流畅的按键响应，模拟物理键盘的输入体验
- 🔌 **简单集成**：可无缝替换 `UITextField` 和 `UITextView` 的输入方式

### **适用场景**
- 支付输入（金额、密码）
- 表单填写（身份证、手机号）
- 验证码输入（6 位、4 位）
- 其他需要自定义数字键盘的场景

  DESC

  s.homepage         = 'https://github.com/yue5yueliang/ZHHNumberKeyboard'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '桃色三岁' => '136769890@qq.com' }
  s.source           = { :git => 'https://github.com/yue5yueliang/ZHHNumberKeyboard.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'

  # 源文件路径，指明需要包含的源代码文件
  s.source_files = 'ZHHNumberKeyboard/Classes/**/*'

  # 如果需要包含资源文件，可以通过下面的代码添加
  # s.resource_bundles = {
  #   'ZHHNumberKeyboard' => ['ZHHNumberKeyboard/Assets/*.png']
  # }

  # 如果有公共的头文件，可以指定公共头文件路径
  # s.public_header_files = 'Pod/Classes/**/*.h'

  # 如果库依赖其他框架，可以在这里声明依赖
  s.frameworks = 'UIKit'

  # 如果库依赖其他第三方 pod，可以通过 s.dependency 来声明
  # s.dependency 'AFNetworking', '~> 2.3'
end
