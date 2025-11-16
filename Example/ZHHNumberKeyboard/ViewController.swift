//
//  ZHHViewController.swift
//  ZHHNumberKeyboard
//
//  Created by 桃色三岁 on 03/02/2025.
//  Copyright (c) 2025 桃色三岁. All rights reserved.
//

import UIKit
import ZHHNumberKeyboard

class ZHHViewController: UIViewController {
    
    // MARK: - Properties
    
    // 输入框
    private var amountTextField: UITextField!      // 金额输入框（小数点键盘）
    private var idCardTextField: UITextField!      // 身份证输入框（X键盘）
    private var phoneTextField: UITextField!       // 手机号输入框（小数点键盘）
    
    // 键盘
    private var decimalKeyboard: ZHHNumberKeyboard!  // 小数点键盘
    private var idCardKeyboard: ZHHNumberKeyboard!   // 身份证键盘
    
    // 控制开关
    private var soundSwitch: UISwitch!            // 声音开关
    private var hapticSwitch: UISwitch!           // 触感开关
    private var separatorSwitch: UISwitch!        // 分割线开关
    
    // 当前激活的键盘
    private weak var currentKeyboard: ZHHNumberKeyboard?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        title = "数字键盘示例"
        
        setupUI()
        setupKeyboards()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        let margin: CGFloat = 20
        var yOffset: CGFloat = 100
        
        // 标题
        let titleLabel = UILabel(frame: CGRect(x: margin, y: yOffset, width: view.bounds.width - 2 * margin, height: 30))
        titleLabel.text = "📱 功能演示"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .darkGray
        view.addSubview(titleLabel)
        yOffset += 50
        
        // ========== 金额输入框 ==========
        let amountLabel = createLabel(with: "💰 金额输入（小数点键盘）", frame: CGRect(x: margin, y: yOffset, width: 200, height: 20))
        view.addSubview(amountLabel)
        yOffset += 25
        
        amountTextField = createTextField(with: "请输入金额", frame: CGRect(x: margin, y: yOffset, width: view.bounds.width - 2 * margin, height: 45))
        view.addSubview(amountTextField)
        yOffset += 60
        
        // ========== 身份证输入框 ==========
        let idCardLabel = createLabel(with: "🆔 身份证号（X键盘）", frame: CGRect(x: margin, y: yOffset, width: 200, height: 20))
        view.addSubview(idCardLabel)
        yOffset += 25
        
        idCardTextField = createTextField(with: "请输入身份证号", frame: CGRect(x: margin, y: yOffset, width: view.bounds.width - 2 * margin, height: 45))
        view.addSubview(idCardTextField)
        yOffset += 60
        
        // ========== 手机号输入框 ==========
        let phoneLabel = createLabel(with: "📱 手机号（小数点键盘）", frame: CGRect(x: margin, y: yOffset, width: 200, height: 20))
        view.addSubview(phoneLabel)
        yOffset += 25
        
        phoneTextField = createTextField(with: "请输入手机号", frame: CGRect(x: margin, y: yOffset, width: view.bounds.width - 2 * margin, height: 45))
        view.addSubview(phoneTextField)
        yOffset += 60
        
        // ========== 分割线 ==========
        let separator = UIView(frame: CGRect(x: margin, y: yOffset, width: view.bounds.width - 2 * margin, height: 1))
        separator.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        view.addSubview(separator)
        yOffset += 20
        
        // ========== 反馈控制 ==========
        let settingsLabel = createLabel(with: "⚙️ 反馈设置", frame: CGRect(x: margin, y: yOffset, width: 200, height: 20))
        settingsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(settingsLabel)
        yOffset += 35
        
        // 声音开关
        let soundLabel = createLabel(with: "🔊 按键音效", frame: CGRect(x: margin, y: yOffset, width: 150, height: 30))
        view.addSubview(soundLabel)
        
        soundSwitch = UISwitch(frame: CGRect(x: view.bounds.width - margin - 51, y: yOffset, width: 51, height: 31))
        soundSwitch.isOn = true
        soundSwitch.addTarget(self, action: #selector(soundSwitchChanged(_:)), for: .valueChanged)
        view.addSubview(soundSwitch)
        yOffset += 45
        
        // 触感开关
        let hapticLabel = createLabel(with: "📳 触觉反馈", frame: CGRect(x: margin, y: yOffset, width: 150, height: 30))
        view.addSubview(hapticLabel)
        
        hapticSwitch = UISwitch(frame: CGRect(x: view.bounds.width - margin - 51, y: yOffset, width: 51, height: 31))
        hapticSwitch.isOn = true
        hapticSwitch.addTarget(self, action: #selector(hapticSwitchChanged(_:)), for: .valueChanged)
        view.addSubview(hapticSwitch)
        yOffset += 45
        
        // 分割线开关
        let separatorLabel = createLabel(with: "━ 顶部分割线", frame: CGRect(x: margin, y: yOffset, width: 150, height: 30))
        view.addSubview(separatorLabel)
        
        separatorSwitch = UISwitch(frame: CGRect(x: view.bounds.width - margin - 51, y: yOffset, width: 51, height: 31))
        separatorSwitch.isOn = true
        separatorSwitch.addTarget(self, action: #selector(separatorSwitchChanged(_:)), for: .valueChanged)
        view.addSubview(separatorSwitch)
        yOffset += 60
        
        // ========== 提示信息 ==========
        let tipLabel = UILabel(frame: CGRect(x: margin, y: yOffset, width: view.bounds.width - 2 * margin, height: 60))
        tipLabel.text = "💡 提示：点击输入框即可使用自定义数字键盘\n开关可实时控制所有键盘的反馈效果"
        tipLabel.font = UIFont.systemFont(ofSize: 13)
        tipLabel.textColor = .gray
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        view.addSubview(tipLabel)
        
        // 添加点击手势收起键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupKeyboards() {
        // 创建小数点键盘
        decimalKeyboard = ZHHNumberKeyboard()
        decimalKeyboard.keyboardType = .decimal
        decimalKeyboard.enableClickSound = true
        decimalKeyboard.enableHapticFeedback = true
        decimalKeyboard.delegate = self
        decimalKeyboard.doneButtonBackgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0) // 蓝色
        
        // 创建身份证键盘
        idCardKeyboard = ZHHNumberKeyboard()
        idCardKeyboard.keyboardType = .idCard
        idCardKeyboard.enableClickSound = true
        idCardKeyboard.enableHapticFeedback = true
        idCardKeyboard.delegate = self
        idCardKeyboard.doneButtonBackgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.4, alpha: 1.0) // 绿色
        
        // 为输入框设置键盘
        amountTextField.inputView = decimalKeyboard
        idCardTextField.inputView = idCardKeyboard
        phoneTextField.inputView = decimalKeyboard
        
        // 设置代理
        amountTextField.delegate = self
        idCardTextField.delegate = self
        phoneTextField.delegate = self
        
        // 监听输入变化
        amountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        idCardTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // 初始化完成按钮状态
        decimalKeyboard.keyboardInputDidChange("")
        idCardKeyboard.keyboardInputDidChange("")
    }
    
    // MARK: - Helper Methods
    
    private func createLabel(with text: String, frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .darkGray
        return label
    }
    
    private func createTextField(with placeholder: String, frame: CGRect) -> UITextField {
        let textField = UITextField(frame: frame)
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .darkText
        
        // 添加左边距
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        return textField
    }
    
    // MARK: - Switch Actions
    
    @objc private func soundSwitchChanged(_ sender: UISwitch) {
        let enabled = sender.isOn
        decimalKeyboard.enableClickSound = enabled
        idCardKeyboard.enableClickSound = enabled
        print("🔊 按键音效: \(enabled ? "开启" : "关闭")")
    }
    
    @objc private func hapticSwitchChanged(_ sender: UISwitch) {
        let enabled = sender.isOn
        decimalKeyboard.enableHapticFeedback = enabled
        idCardKeyboard.enableHapticFeedback = enabled
        print("📳 触觉反馈: \(enabled ? "开启" : "关闭")")
    }
    
    @objc private func separatorSwitchChanged(_ sender: UISwitch) {
        let enabled = sender.isOn
        decimalKeyboard.showTopSeparator = enabled
        idCardKeyboard.showTopSeparator = enabled
        print("━ 顶部分割线: \(enabled ? "显示" : "隐藏")")
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension ZHHViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 记录当前活跃的键盘
        if textField == amountTextField || textField == phoneTextField {
            currentKeyboard = decimalKeyboard
        } else if textField == idCardTextField {
            currentKeyboard = idCardKeyboard
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        
        // 针对不同输入框的验证逻辑
        if textField == amountTextField {
            // 金额输入：限制小数点后两位
            let components = newText.components(separatedBy: ".")
            if components.count > 2 {
                return false // 不允许多个小数点
            }
            if components.count == 2 && components[1].count > 2 {
                return false // 小数点后最多两位
            }
        } else if textField == idCardTextField {
            // 身份证：限制18位
            if newText.count > 18 {
                return false
            }
        } else if textField == phoneTextField {
            // 手机号：限制11位，不允许小数点
            if string == "." {
                return false // 手机号不允许小数点
            }
            if newText.count > 11 {
                return false
            }
        }
        
        print("📝 输入内容: \(newText)")
        return true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // 更新对应键盘的完成按钮状态
        if textField == amountTextField || textField == phoneTextField {
            decimalKeyboard.keyboardInputDidChange(textField.text ?? "")
        } else if textField == idCardTextField {
            idCardKeyboard.keyboardInputDidChange(textField.text ?? "")
        }
    }
}

// MARK: - ZHHNumberKeyboardDelegate

extension ZHHViewController: ZHHNumberKeyboardDelegate {
    
    func numberKeyboardDidTapDone(_ keyboard: ZHHNumberKeyboard) {
        if keyboard == decimalKeyboard {
            print("✅ 小数点键盘 - 完成按钮被点击")
            if amountTextField.isFirstResponder {
                print("   金额: \(amountTextField.text ?? "")")
            } else if phoneTextField.isFirstResponder {
                print("   手机号: \(phoneTextField.text ?? "")")
            }
        } else if keyboard == idCardKeyboard {
            print("✅ 身份证键盘 - 完成按钮被点击")
            print("   身份证号: \(idCardTextField.text ?? "")")
        }
        
        // 收起键盘
        view.endEditing(true)
    }
}

