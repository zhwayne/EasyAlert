//
//  Action.swift
//  EasyAlert
//
//  Created by iya on 2021/7/27.
//

import UIKit

public final class Action {
    
    public typealias Handler = (Action) -> Void
    
    /// 当 allowAutoDismiss 为 true 时，点击 action view 后，alert 会立即消失。
    /// 否则开发者需要自己手动关闭 alert。
    public var allowAutoDismiss: Bool = true

    public let style: Style
    
    /// action view 的标题
    public let title: String?
    
    let handler: Handler?
    
    var view: (UIView & ActionCustomizable)?
    
    weak var representationView: ActionCustomViewRepresentationView?
    
    public init(title: String, style: Style, handler: Handler? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    public init(view: UIView & ActionCustomizable, handler: Handler? = nil) {
        self.view = view
        self.title = view.title
        self.style = view.style
        self.handler = handler
    }
    
    deinit {
        view?.removeFromSuperview()
    }
    
    /// 是否可用
    ///
    /// isEnabled 为 true 时，action view 将无法点击。
    public var isEnabled: Bool = true {
        didSet {
            guard let representationView = view?.superview as? ActionCustomViewRepresentationView else {
                return
            }
            representationView.isEnabled = isEnabled
        }
    }
}

public extension Action {
    
    /// Action 风格
    ///
    /// - `default`: 默认
    /// - cancel:  取消
    /// - destructive: 破坏性操作
    enum Style : Hashable {
        case `default`, cancel, destructive
    }
}
