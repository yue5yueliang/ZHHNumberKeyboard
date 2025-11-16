//
//  ZHHNumberKeyboardHelper.swift
//  ZHHNumberKeyboard
//
//  Created by 桃色三岁 on 2025/3/2.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

/// 数字键盘辅助工具类
public class ZHHNumberKeyboardHelper {
    
    /// 获取安全区域边距
    /// - Returns: 当前窗口的安全区域边距
    static func safeAreaInsets() -> UIEdgeInsets {
        var window: UIWindow?
        
        // 通过 UIWindowScene 获取当前 keyWindow（适配 iOS 13.0+）
        let scenes = UIApplication.shared.connectedScenes
        for scene in scenes {
            if let windowScene = scene as? UIWindowScene {
                for w in windowScene.windows {
                    if w.isKeyWindow {
                        window = w
                        break
                    }
                }
                if window != nil { break }
            }
        }
        
        return window?.safeAreaInsets ?? .zero
    }
    
    /// 计算数字键盘的默认 Frame
    /// - Returns: 根据屏幕尺寸计算出的键盘 Frame
    static func keyboardFrame() -> CGRect {
        // 获取屏幕宽度，适配横竖屏
        let screenBounds = UIScreen.main.bounds
        let width = min(screenBounds.width, screenBounds.height)
        
        // 高度按照宽度的 0.32 倍计算，最终高度是两倍
        let height = Int(width * 0.32) * 2
        
        // 加上底部安全区域（刘海屏适配）
        let safeAreaBottom = safeAreaInsets().bottom
        
        return CGRect(x: 0, y: 0, width: width, height: CGFloat(height) + safeAreaBottom)
    }
    
    /// 生成纯色 UIImage
    /// - Parameters:
    ///   - color: 需要生成图片的颜色
    ///   - size: 图片的尺寸
    /// - Returns: 生成的 UIImage
    static func image(with color: UIColor, size: CGSize) -> UIImage? {
        // 参数检查，避免创建无效图片
        guard color.cgColor.alpha > 0, size.width > 0, size.height > 0 else {
            return nil
        }
        
        // 开启图形上下文，自动适配屏幕分辨率
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // 设置填充颜色
        ctx.setFillColor(color.cgColor)
        // 绘制矩形填充颜色
        ctx.fill(CGRect(origin: .zero, size: size))
        
        // 生成 UIImage
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 获取键盘删除按钮图标（使用系统 SF Symbols）
    /// - Returns: 删除按钮的 UIImage
    static func deleteIcon() -> UIImage? {
        // 使用系统 SF Symbols 图标（iOS 13.0+）
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium, scale: .medium)
        guard let image = UIImage(systemName: "delete.backward", withConfiguration: config) else {
            return nil
        }
        
        // 设置为黑色（适配深色/浅色模式）
        return image.withTintColor(.black, renderingMode: .alwaysOriginal)
    }
    
    /// 获取输入视图 (UITextInput) 中当前选中的文本范围
    /// - Parameter inputView: 符合 UITextInput 协议的输入控件（如 UITextView、UITextField）
    /// - Returns: 当前选中的文本范围，返回 NSRange 结构体
    static func selectedRange(in inputView: UITextInput) -> NSRange {
        // 获取文本的起始位置（beginningOfDocument 不是可选类型）
        let beginning = inputView.beginningOfDocument
        
        // 获取当前选中的文本范围
        guard let selectedRange = inputView.selectedTextRange else {
            return NSRange(location: 0, length: 0)
        }
        
        // 获取选中文本的起始位置和结束位置
        let selectionStart = selectedRange.start
        let selectionEnd = selectedRange.end
        
        // 计算选中文本的起始位置（距离文本开头的偏移量）
        let location = inputView.offset(from: beginning, to: selectionStart)
        
        // 计算选中文本的长度（起始位置到结束位置的偏移量）
        let length = inputView.offset(from: selectionStart, to: selectionEnd)
        
        return NSRange(location: location, length: length)
    }
    
    /// 播放系统默认的输入点击音效（通常用于键盘点击）
    static func playClickAudio() {
        UIDevice.current.playInputClick()
    }
    
    /// 根据给定颜色生成稍暗的颜色（用于高亮状态）
    /// - Parameters:
    ///   - color: 原始颜色
    ///   - amount: 亮度减少量（0-1之间）
    /// - Returns: 调暗后的颜色
    static func darken(_ color: UIColor, by amount: CGFloat) -> UIColor {
        guard amount >= 0, amount <= 1.0 else {
            return color
        }
        
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        // 提取 HSB 值
        if color.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            // 降低亮度生成高亮色
            return UIColor(hue: h, saturation: s, brightness: max(0, b - amount), alpha: a)
        }
        
        // 如果无法提取 HSB，返回原色
        return color
    }
}

