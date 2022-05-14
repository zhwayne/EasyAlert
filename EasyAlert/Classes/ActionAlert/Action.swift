//
//  Action.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

public final class Action {
    
    public typealias CustomizedView = UIView & ActionCustomizable
    
    public typealias Handelr = (Action) -> Void
    
    public static var defaultViewType: CustomizedView.Type = DefaultActionView.self
    public static var defaultLayout: ActionLayoutable = DefaultActionLayout()
    
    let handler: Handelr?
    
    let view: CustomizedView
    
    public var allowAutoDismiss: Bool = true
    
    public convenience init(title: String, style: Style, handler: Handelr? = nil) {
        let view = Action.defaultViewType.init(style: style)
        view.title = title
        self.init(view: view, handler: handler)
    }
    
    public required init(view: CustomizedView, handler: Handelr? = nil) {
        self.view = view
        self.handler = handler
    }
    
    deinit {
        view.removeFromSuperview()
    }
}

extension Action {
    
    public var style: Style { view.style }
    
    public var title: String? {
        get { view.title }
        set { view.title = newValue }
    }
    
    public var isEnabled: Bool {
        get {
            guard let control = view.superview as? UIControl else {
                return true
            }
            return control.isEnabled
        }
        set {
            guard let control = view.superview as? UIControl else {
                return
            }
            control.isEnabled = newValue
        }
    }
}

public extension Action {
    
    enum Style : Hashable {
        case `default`, cancel, destructive
        
        internal var attributes: [Action.Key : Any] {
            switch self {
            case .default: return DefaultActionAttributes
            case .cancel:  return CancelActionAttributes
            case .destructive: return DestructiveActionAttributes
            }
        }
        
        static var globalAttributes: [Action.Key : Any] {
            return GlobalActionAttributes
        }
    }
    
    enum State : Hashable {
        case normal, disabled
    }
}

public extension Action {
    
    struct Key : Hashable, Equatable, RawRepresentable {
        public var rawValue: String
        public typealias RawValue = String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

public extension Action.Key {
    
    /// A UIFont value
    static let font = Action.Key(rawValue: "font")
    
    /// A UIColor value
    static let textColor = Action.Key(rawValue: "textColor")
    
    /// A UIColor value
    static let itemBackgroundColor = Action.Key(rawValue: "itemBackgroundColor")
    
    /// A UIEdgeInsets value
    static let itemEdgeInsets = Action.Key(rawValue: "itemEdgeInsets")
    
    /// A CGFloat value
    static let itemCornerRadius = Action.Key(rawValue: "itemCornerRadius")
    
    /// A CGFloat value
    static let itemHeight = Action.Key(rawValue: "itemHeight")
}

public extension Action.Key {
    
    /// A UIColor value
    static let backgroundColor = Action.Key(rawValue: "backgroundColor")
    
    /// A UIColor value
    static let separatorColor = Action.Key(rawValue: "separatorColor")
    
    /// A CGFloat value
    static let itemSpacing = Action.Key(rawValue: "itemSpacing")
}

public extension Action {
    
    static let roundCornerRadius: CGFloat = -999
}

private var GlobalActionAttributes: [Action.Key : Any] = [
    .backgroundColor: UIColor.white,
    .separatorColor: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1),
    .itemSpacing: CGFloat(0)
]

private var DefaultActionAttributes: [Action.Key : Any] = [
    .font: UIFont.systemFont(ofSize: 17, weight: .medium),
    .textColor: UIColor.systemBlue,
    .itemBackgroundColor: UIColor.white,
    .itemEdgeInsets: UIEdgeInsets.zero,
    .itemCornerRadius: CGFloat(0),
    .itemHeight: CGFloat(44.0)
]

private var CancelActionAttributes: [Action.Key : Any] = [
    .font: UIFont.systemFont(ofSize: 17),
    .textColor: UIColor.systemGray,
    .itemBackgroundColor: UIColor.white,
    .itemEdgeInsets: UIEdgeInsets.zero,
    .itemCornerRadius: CGFloat(0),
    .itemHeight: CGFloat(44.0)
]

private var DestructiveActionAttributes: [Action.Key : Any] = [
    .font: UIFont.systemFont(ofSize: 17, weight: .medium),
    .textColor: UIColor.systemRed,
    .itemBackgroundColor: UIColor.white,
    .itemEdgeInsets: UIEdgeInsets.zero,
    .itemCornerRadius: CGFloat(0),
    .itemHeight: CGFloat(44.0)
]

extension Action {
    
    /// 为 Action.Style 注册预定义样式
    /// - Parameters:
    ///   - attributes: 样式属性
    ///   - style: action style
    public static func register(attributes: [Action.Key : Any], for style: Style) {
        objc_sync_enter(1)
        defer { objc_sync_exit(1) }
        switch style {
        case .default:
            attributes.forEach { key, value in
                DefaultActionAttributes[key] = value
            }
        case .cancel:
            attributes.forEach { key, value in
                CancelActionAttributes[key] = value
            }
        case .destructive:
            attributes.forEach { key, value in
                DestructiveActionAttributes[key] = value
            }
        }
    }
    
    public static func registerGlobal(attributes: [Action.Key : Any]) {
        objc_sync_enter(1)
        defer { objc_sync_exit(1) }
        attributes.forEach { key, value in
            GlobalActionAttributes[key] = value
        }
    }
}
