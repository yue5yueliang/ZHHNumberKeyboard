//
//  ZHHNumberKeyboardButton.swift
//  ZHHNumberKeyboard
//
//  Created by 桃色三岁 on 2025/3/2.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

/// 数字键盘按钮类
/// 支持为不同状态设置背景色
public class ZHHNumberKeyboardButton: UIButton {
    
    /// 为不同状态设置背景色（转换为背景图片）
    /// - Parameters:
    ///   - backgroundColor: 背景颜色
    ///   - state: 按钮状态
    public func setBackgroundColor(_ backgroundColor: UIColor, for state: UIControl.State) {
        let backgroundImage = ZHHNumberKeyboardHelper.image(with: backgroundColor, size: CGSize(width: 1, height: 1))
        setBackgroundImage(backgroundImage, for: state)
    }
}

