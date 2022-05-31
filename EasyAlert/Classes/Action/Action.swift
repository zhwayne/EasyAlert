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
    
    public var allowAutoDismiss: Bool = true

    public let style: Style
    
    public let title: String?
    
    let handler: Handelr?
    
    var view: CustomizedView!
    
    public init(title: String, style: Style, handler: Handelr? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    public init(view: CustomizedView, handler: Handelr? = nil) {
        self.view = view
        self.title = view.title
        self.style = view.style
        self.handler = handler
    }
    
    deinit {
        view?.removeFromSuperview()
    }
    
    public var isEnabled: Bool = true {
        didSet {
            guard let representationView = view?.superview as? ActionRepresentationView else {
                return
            }
            representationView.isEnabled = isEnabled
        }
    }
}

public extension Action {
    
    enum Style : Hashable {
        case `default`, cancel, destructive
    }
}
