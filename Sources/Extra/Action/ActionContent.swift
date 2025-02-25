//
//  ActionContent.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

/// 自定义 action view 基础协议
@MainActor public protocol ActionContent : Dismissible {
    
    /// action 标题
    var title: String? { get set }
    
    /// action 是否为高亮，即按压状态。
    ///
    /// 开发者可以自行根据此状态更新 UI 风格。
    var isHighlighted: Bool { get set }
    
    /// action 是否为可用。
    ///
    /// 开发者可以自行根据此状态更新 UI 风格。
    var isEnabled: Bool { get set }
    
    /// action 的风格
    var style: Action.Style { get }
    
    var view: UIView { get }
}

extension ActionContent where Self: UIView {
    
    public var view: UIView { self }
}
