//
//  ZHHNumberKeyboard.swift
//  ZHHNumberKeyboard
//
//  Created by 桃色三岁 on 2022/5/11.
//  Copyright © 2022 桃色三岁. All rights reserved.
//

import UIKit

/// 按钮 Tag 定义说明：
/// - 数字 0-9：tag = 48-57 (对应 ASCII 码)
/// - 小数点/X：tag = 46 (ASCII 码的 '.')
/// - 删除键：tag = 127 (ASCII 码的 DEL)
/// - 确定按钮：tag = -2 (自定义负数标识)

/// 键盘类型枚举
@objc public enum ZHHNumberKeyboardType: Int {
    /// 展示小数点（用于金额、浮点数等输入）
    case decimal = 0
    /// 展示 "X"（用于身份证输入）
    case idCard = 1
}

/// 数字键盘的代理协议，提供可选的回调方法
@objc public protocol ZHHNumberKeyboardDelegate: AnyObject {
    /// 当用户点击"完成"按钮时触发此方法
    /// - Parameter keyboard: 触发事件的数字键盘实例
    @objc optional func numberKeyboardDidTapDone(_ keyboard: ZHHNumberKeyboard)
}

/// 数字键盘主类
/// 模仿微信的数字键盘，支持小数点/身份证键盘、声音触觉反馈、高度自定义
@objc public class ZHHNumberKeyboard: UIView, UIInputViewAudioFeedback {
    
    // MARK: - 颜色常量定义
    
    /// 键盘背景色 - #F5F5F5 (96% 白色)，与系统键盘一致
    private static let keyboardBackgroundColor = UIColor(white: 0.96, alpha: 1.0) // #F5F5F5 (245)
    
    /// 普通按钮背景色 - #FFFFFF (纯白色)
    private static let buttonBackgroundColor = UIColor.white // #FFFFFF (255)
    
    /// 普通按钮高亮色 - #F0F0F0 (94% 白色)
    private static let buttonHighlightColor = UIColor(white: 0.94, alpha: 1.0) // #F0F0F0 (240)
    
    /// 确定按钮默认背景色（鲜绿色）- 类似微信
    private static let defaultDoneButtonBackgroundColor = UIColor(red: 6.0/255.0, green: 193.0/255.0, blue: 96.0/255.0, alpha: 1.0)
    
    /// 按钮文字颜色（黑色）
    private static let buttonTextColor = UIColor.black
    
    /// 确定按钮文字颜色（白色）
    private static let doneButtonTextColor = UIColor.white
    
    /// 顶部分割线颜色（系统标准灰）
    private static let separatorColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0)
    
    // MARK: - Public Properties
    
    /// 确定按钮的背景颜色（默认绿色）
    /// 可自定义键盘"确定"按钮的背景颜色，例如修改为主题色。
    @objc public var doneButtonBackgroundColor: UIColor = defaultDoneButtonBackgroundColor {
        didSet {
            updateKeyboardLayout()
        }
    }
    
    /// 键盘类型（默认 `ZHHNumberKeyboardTypeDecimal`）
    /// 可设置不同类型的数字键盘，例如整数键盘、小数键盘等。
    @objc public var keyboardType: ZHHNumberKeyboardType = .decimal {
        didSet {
            updateKeyboardLayout()
        }
    }
    
    /// 是否启用按键音效（默认 YES）
    /// 点击按键时播放系统键盘点击音效
    @objc public var enableClickSound: Bool = true
    
    /// 是否启用触觉反馈（默认 YES）
    /// 点击按键时产生轻微震动反馈（需要设备支持）
    @objc public var enableHapticFeedback: Bool = true
    
    /// 是否显示顶部分割线（默认 YES）
    /// 在键盘顶部显示一条分割线，用于视觉分隔
    @objc public var showTopSeparator: Bool = true {
        didSet {
            topSeparatorView.isHidden = !showTopSeparator
        }
    }
    
    /// 顶部分割线颜色（默认浅灰色）
    /// 可自定义分割线的颜色
    @objc public var topSeparatorColor: UIColor = separatorColor {
        didSet {
            topSeparatorView.backgroundColor = topSeparatorColor
        }
    }
    
    /// 完成按钮点击回调
    /// 代理方法，监听用户点击键盘"完成"按钮的事件。
    @objc public weak var delegate: ZHHNumberKeyboardDelegate?
    
    // MARK: - Private Properties
    
    /// 长按删除定时器（使用 CADisplayLink 替代 NSTimer，避免循环引用）
    private var deleteDisplayLink: CADisplayLink?
    
    /// 绑定的第一响应者（当前正在输入的 UITextField 或 UITextView）
    private weak var firstResponder: (UIView & UIKeyInput)?
    
    /// 所有按钮的数组集合（包含 0-9 数字键、小数点/X键、删除键、确定键）
    private var buttons: [ZHHNumberKeyboardButton] = []
    
    /// 触觉反馈生成器（用于产生震动反馈）
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    /// 顶部分割线视图
    private let topSeparatorView = UIView()
    
    // MARK: - Lifecycle
    
    /// 初始化方法
    /// 创建键盘视图并设置默认配置
    @objc public override init(frame: CGRect) {
        // 获取适配屏幕的键盘尺寸
        let keyboardFrame = ZHHNumberKeyboardHelper.keyboardFrame()
        super.init(frame: keyboardFrame)
        
        // 设置键盘背景色
        backgroundColor = Self.keyboardBackgroundColor
        
        // 初始化触觉反馈生成器（Light 级别的震动强度）
        impactFeedbackGenerator.prepare() // 预热，提高首次触发响应速度
        
        // 初始化 UI 组件
        initUI()
        initTopSeparator()
    }
    
    @objc public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 安全区域变化时的回调
    /// 主要用于适配刘海屏等设备的底部安全区域
    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setNeedsLayout() // 触发重新布局以适配新的安全区域
    }
    
    /// 析构方法
    /// 清理定时器，防止内存泄漏
    deinit {
        cleanDisplayLink()
        print("***> \(#function)")
    }
    
    // MARK: - Public Methods
    
    /// 监听键盘输入内容变化
    /// 根据输入内容更新确定按钮的可用状态
    /// - Parameter currentText: 当前输入框中的文本内容
    @objc public func keyboardInputDidChange(_ currentText: String) {
        updateDoneButtonState(hasInput: currentText.count > 0)
    }
    
    // MARK: - UI Initialization
    
    /// 初始化顶部分割线
    /// 创建一个细线视图，位于键盘顶部
    private func initTopSeparator() {
        topSeparatorView.backgroundColor = topSeparatorColor
        topSeparatorView.isHidden = !showTopSeparator
        addSubview(topSeparatorView)
    }
    
    /// 初始化键盘 UI
    /// 创建所有按键（0-9、小数点/X、删除、确定）并配置样式
    private func initUI() {
        buttons = []
        
        // 创建 14 个按钮：0-9 共 10 个数字键 + 小数点/X键 + 删除键 + 确定键 + 占位按钮
        for i in 0..<14 {
            let item = ZHHNumberKeyboardButton(type: .custom)
            item.layer.cornerRadius = 5
            item.layer.masksToBounds = true
            
            // 根据索引配置不同按钮的功能和样式
            if i == 10 {
                // 小数点/X 按钮（第 11 个按钮，索引 10）
                item.tag = 46 // ASCII 码的 '.'
                if keyboardType == .decimal {
                    item.setTitle(".", for: .normal)
                } else if keyboardType == .idCard {
                    item.setTitle("X", for: .normal)
                }
            } else if i == 11 {
                // 删除键（第 12 个按钮，索引 11）
                item.tag = 127 // ASCII 码的 DEL
                if let deleteIcon = ZHHNumberKeyboardHelper.deleteIcon() {
                    item.setImage(deleteIcon, for: .normal)
                }
                
                // 添加长按手势以支持连续删除
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteItemLongPress(_:)))
                longPressGesture.minimumPressDuration = 0.3 // 设置为 0.3 秒，更快识别长按（默认 0.5 秒）
                item.addGestureRecognizer(longPressGesture)
            } else if i == 12 {
                // 确定按钮（第 13 个按钮，索引 12）
                item.tag = -2 // 自定义负数标识
                item.setTitle("确定", for: .normal)
                item.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
            } else {
                // 数字键 0-9（索引 0-9 和 13）
                // 索引 0-9 对应数字 1-9 和 0，索引 13 暂不使用
                if i < 9 {
                    // 1-9 按钮（索引 0-8）
                    item.tag = 49 + i // ASCII 码 '1' = 49
                    item.setTitle("\(i + 1)", for: .normal)
                } else {
                    // 0 按钮（索引 9）
                    item.tag = 48 // ASCII 码 '0' = 48
                    item.setTitle("0", for: .normal)
                }
            }
            
            // 设置按钮的颜色和字体
            if item.tag != -2 {
                // 普通按钮（数字、小数点、删除）
                item.setBackgroundColor(Self.buttonBackgroundColor, for: .normal)
                item.setBackgroundColor(Self.buttonHighlightColor, for: .highlighted) // 备用高亮色
                item.setTitleColor(Self.buttonTextColor, for: .normal)
                item.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 22)
            } else {
                // 确定按钮（特殊样式）
                // 根据 doneButtonBackgroundColor 生成协调的高亮颜色
                let highlightColor = ZHHNumberKeyboardHelper.darken(doneButtonBackgroundColor, by: 0.1)
                
                item.setBackgroundColor(doneButtonBackgroundColor, for: .normal)
                item.setBackgroundColor(highlightColor, for: .highlighted)
                item.setTitleColor(Self.doneButtonTextColor, for: .normal)
            }
            
            // 添加到按钮数组并设置点击事件
            buttons.append(item)
            item.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
            addSubview(item)
        }
    }
    
    // MARK: - Layout
    
    /// 布局子视图
    /// 计算并设置所有按钮和分割线的位置
    /// 键盘布局：
    /// ┌───────────────────────────┐
    /// │ 1  2  3  DEL              │
    /// │ 4  5  6  ┌──────────────┐ │
    /// │ 7  8  9  │              │ │
    /// │ 0     .  │    确 定      │ │
    /// └─────────┴──────────────┴─┘
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let totalWidth = bounds.width
        let totalHeight = bounds.height - safeAreaInsets.bottom
        
        // 1. 顶部分割线布局
        let separatorHeight: CGFloat = 0.5 // 系统标准分割线高度
        topSeparatorView.frame = CGRect(x: 0, y: 0, width: totalWidth, height: separatorHeight)
        
        // 2. 计算按键布局参数
        let margin: CGFloat = 10.0        // 左右边距
        let spacing: CGFloat = 10.0       // 按键间距
        let topMargin: CGFloat = 10.0     // 第一排距离顶部的间距
        let keyWidth = (totalWidth - 2 * margin - 3 * spacing) / 4.0   // 每列 4 个按钮
        let keyHeight = (totalHeight - 3 * spacing - topMargin) / 4.0  // 每行 4 个按钮
        
        // 3. 布局数字键 1~9（3x3 网格）
        for i in 0..<9 {
            let row = i / 3  // 行号（0-2）
            let col = i % 3  // 列号（0-2）
            let x = margin + CGFloat(col) * (keyWidth + spacing)
            let y = topMargin + CGFloat(row) * (keyHeight + spacing)
            viewWithTag(49 + i)?.frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
        }
        
        // 4. 布局 "0" 按钮（横跨 2 列）
        viewWithTag(48)?.frame = CGRect(x: margin,
                                        y: topMargin + 3 * (keyHeight + spacing),
                                        width: keyWidth * 2 + spacing,
                                        height: keyHeight)
        
        // 5. 布局小数点/X 按钮（第 4 行第 3 列）
        viewWithTag(46)?.frame = CGRect(x: margin + 2 * (keyWidth + spacing),
                                        y: topMargin + 3 * (keyHeight + spacing),
                                        width: keyWidth,
                                        height: keyHeight)
        
        // 6. 布局删除键（第 1 行第 4 列）
        viewWithTag(127)?.frame = CGRect(x: margin + 3 * (keyWidth + spacing),
                                        y: topMargin,
                                        width: keyWidth,
                                        height: keyHeight)
        
        // 7. 布局确定按钮（纵跨 3 行，第 2-4 行第 4 列）
        viewWithTag(-2)?.frame = CGRect(x: margin + 3 * (keyWidth + spacing),
                                        y: topMargin + keyHeight + spacing,
                                        width: keyWidth,
                                        height: 3 * keyHeight + 2 * spacing)
    }
    
    // MARK: - Update Methods
    
    /// 更新键盘布局
    /// 当 doneButtonBackgroundColor 或 keyboardType 改变时调用
    private func updateKeyboardLayout() {
        for button in buttons {
            if button.tag == 46 {
                // 更新小数点/X 按钮的文本
                if keyboardType == .decimal {
                    button.setTitle(".", for: .normal)
                } else if keyboardType == .idCard {
                    button.setTitle("X", for: .normal)
                }
            } else if button.tag == -2 {
                // 更新确定按钮的颜色（正常色和高亮色）
                let highlightColor = ZHHNumberKeyboardHelper.darken(doneButtonBackgroundColor, by: 0.1)
                
                button.setBackgroundColor(doneButtonBackgroundColor, for: .normal)
                button.setBackgroundColor(highlightColor, for: .highlighted)
            }
        }
    }
    
    /// 更新确定按钮的可用状态
    /// - Parameter hasInput: 是否有输入内容
    private func updateDoneButtonState(hasInput: Bool) {
        for button in buttons {
            if button.tag == -2 { // 确定按钮
                button.isEnabled = hasInput
                button.alpha = hasInput ? 1.0 : 0.7 // 有内容时不透明，无内容时半透明
            }
        }
    }
    
    // MARK: - Input Handling
    
    /// 处理键盘输入
    /// 根据按钮的 tag 值分发到不同的处理方法
    /// - Parameter tag: 按钮的 tag 值
    private func handleInput(with tag: Int) {
        switch tag {
        case 46:  // 小数点或 X
            if keyboardType == .decimal {
                insertText(".")
            } else {
                insertText("X")
            }
        case 127:  // 删除键
            handleDeleteButtonTap()
        case -2:  // 确定按钮
            handleDoneButtonTap()
        case 48...57:  // 数字 0-9
            handleNumberButtonTap(decimal: tag - 48)
        default:
            break
        }
    }
    
    /// 插入文本到第一响应者
    /// 会先调用 delegate 方法进行验证，通过后才插入
    /// - Parameter text: 要插入的文本
    private func insertText(_ text: String) {
        guard let firstResponder = firstResponder else { return }
        
        if let textField = firstResponder as? UITextField {
            // 处理 UITextField
            let range = ZHHNumberKeyboardHelper.selectedRange(in: textField)
            let nsRange = NSRange(location: range.location, length: range.length)
            
            var shouldInsert = true
            if let delegate = textField.delegate {
                shouldInsert = delegate.textField?(textField, shouldChangeCharactersIn: nsRange, replacementString: text) ?? true
            }
            
            if shouldInsert {
                firstResponder.insertText(text)
            }
        } else if let textView = firstResponder as? UITextView {
            // 处理 UITextView
            let range = ZHHNumberKeyboardHelper.selectedRange(in: textView)
            let nsRange = NSRange(location: range.location, length: range.length)
            
            var shouldInsert = true
            if let delegate = textView.delegate {
                shouldInsert = delegate.textView?(textView, shouldChangeTextIn: nsRange, replacementText: text) ?? true
            }
            
            if shouldInsert {
                firstResponder.insertText(text)
            }
        } else {
            // 其他实现了 UIKeyInput 协议的控件
            firstResponder.insertText(text)
        }
    }
    
    /// 处理删除键点击
    /// 删除光标前的一个字符
    private func handleDeleteButtonTap() {
        if firstResponder?.hasText == true {
            firstResponder?.deleteBackward()
        }
    }
    
    /// 处理确定按钮点击
    /// 收起键盘并调用代理方法
    private func handleDoneButtonTap() {
        firstResponder?.resignFirstResponder()
        delegate?.numberKeyboardDidTapDone?(self)
    }
    
    /// 处理数字按钮点击
    /// - Parameter decimal: 数字值 (0-9)
    private func handleNumberButtonTap(decimal: Int) {
        insertText("\(decimal)")
    }
    
    // MARK: - Long Press Delete
    
    /// 处理删除键的长按手势
    /// 长按时启动定时器，实现连续快速删除
    /// - Parameter longPress: 长按手势识别器
    @objc private func deleteItemLongPress(_ longPress: UILongPressGestureRecognizer) {
        guard let deleteButton = viewWithTag(127) as? UIButton else { return }
        
        if longPress.state == .began {
            // 长按开始：取消所有 Touch 事件，防止与点击冲突
            deleteButton.cancelTracking(with: nil)
            
            // 显示高亮状态
            deleteButton.isHighlighted = true
            
            // 立即执行第一次删除（带反馈）
            if firstResponder?.hasText == true {
                if enableClickSound {
                    ZHHNumberKeyboardHelper.playClickAudio()
                }
                if enableHapticFeedback {
                    triggerHapticFeedback()
                }
                handleDeleteButtonTap()
            }
            
            // 启动定时删除（使用 CADisplayLink 而非 NSTimer 避免循环引用）
            deleteDisplayLink = CADisplayLink(target: self, selector: #selector(repeatLongPressDelete))
            deleteDisplayLink?.add(to: .main, forMode: .common)
            deleteDisplayLink?.preferredFramesPerSecond = 10 // 每秒删除 10 次（约 0.1 秒一次）
        } else if longPress.state == .ended || longPress.state == .cancelled || longPress.state == .failed {
            // 长按结束：取消高亮并停止定时器
            deleteButton.isHighlighted = false
            cleanDisplayLink()
        }
    }
    
    /// 持续删除（定时器回调）
    /// 直接调用删除方法并触发反馈，避免模拟点击事件导致高亮闪烁
    /// 注意：只停止定时器，不取消高亮状态（用户手指可能还在按钮上）
    @objc private func repeatLongPressDelete() {
        // 检查是否还有内容可以删除
        if firstResponder?.hasText == true {
            // 播放按键音效（如果启用）
            if enableClickSound {
                ZHHNumberKeyboardHelper.playClickAudio()
            }
            
            // 触发触觉反馈（如果启用）
            if enableHapticFeedback {
                triggerHapticFeedback()
            }
            
            // 执行删除操作
            handleDeleteButtonTap()
        } else {
            // 内容已清空，只停止定时器（保持高亮状态，等待用户松手）
            cleanDisplayLink()
        }
    }
    
    // MARK: - Button Actions
    
    /// 按钮点击事件统一入口
    /// 处理声音、触觉反馈，并分发到具体的输入处理方法
    /// - Parameter sender: 被点击的按钮
    @objc private func buttonTouchUpInside(_ sender: ZHHNumberKeyboardButton) {
        // 获取或更新第一响应者
        if firstResponder == nil || firstResponder?.isFirstResponder != true {
            guard let responder = UIView.zhhkb_firstResponder() as? (UIView & UIKeyInput) else {
                return
            }
            firstResponder = responder
        }
        
        // 播放按键音效（如果启用）
        if enableClickSound {
            ZHHNumberKeyboardHelper.playClickAudio()
        }
        
        // 触发触觉反馈（如果启用）
        if enableHapticFeedback {
            triggerHapticFeedback()
        }
        
        // 处理按键输入
        handleInput(with: sender.tag)
    }
    
    // MARK: - UIInputViewAudioFeedback
    
    /// 启用输入点击音效
    /// 实现此协议方法后，playInputClick 才会生效
    public var enableInputClicksWhenVisible: Bool {
        return true
    }
    
    // MARK: - Private Methods
    
    /// 触发触觉反馈
    /// 产生轻微震动，并为下次反馈做准备
    private func triggerHapticFeedback() {
        impactFeedbackGenerator.impactOccurred()
        impactFeedbackGenerator.prepare() // 预热下一次反馈，提高响应速度
    }
    
    /// 清除 CADisplayLink 定时器
    /// 防止内存泄漏
    private func cleanDisplayLink() {
        deleteDisplayLink?.invalidate()
        deleteDisplayLink = nil
        print("***> \(#function)")
    }
}

