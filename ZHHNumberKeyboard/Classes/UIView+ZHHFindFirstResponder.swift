//
//  UIView+ZHHFindFirstResponder.swift
//  ZHHNumberKeyboard
//
//  Created by 桃色三岁 on 2025/3/2.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

/// 查找当前界面的第一响应者
extension UIView {
    
    /// 获取当前窗口中的第一响应者（适配 iOS 13.0+）
    /// - Returns: 当前正在响应输入的 UIView（如果存在）
    @objc public static func zhhkb_firstResponder() -> UIView? {
        var keyWindow: UIWindow?
        
        // 通过 UIWindowScene 获取 keyWindow
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    if window.isKeyWindow {
                        keyWindow = window
                        break
                    }
                }
                if keyWindow != nil { break }
            }
        }
        
        return keyWindow?.zhhkb_findFirstResponder()
    }
    
    /// 递归查找第一响应者
    /// - Returns: 找到的第一响应者视图
    @objc public func zhhkb_findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        
        for view in subviews {
            if let responder = view.zhhkb_findFirstResponder() {
                return responder
            }
        }
        
        return nil
    }
}

