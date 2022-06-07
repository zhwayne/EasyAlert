//
//  AlertDismissible.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import Foundation

public protocol AlertDismissible : AnyObject { }

public extension AlertDismissible where Self: UIView {
    
    /// 获取和 view 关联的 alert。
    var alert: Alertble? {
        var alertble: Alertble?
        for view in sequence(first: superview, next: { $0?.superview }) {
            if let backgroundView = view as? BackgroundView {
                alertble = backgroundView.alert
                break
            }
        }
        return alertble
    }
    
    /// 关掉 alert。
    /// - Parameter completion: 完成回调。
    func dismiss(completion: (() -> Void)? = nil) {
        alert?.dismiss(completion: completion)
    }
}
