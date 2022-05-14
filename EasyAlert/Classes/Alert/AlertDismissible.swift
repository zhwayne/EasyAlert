//
//  AlertDismissible.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import Foundation

public protocol AlertDismissible : AnyObject { }

public extension AlertDismissible where Self: UIView {
    
    var alert: Alertble? {
        var alertble: Alertble?
        for view in sequence(first: superview, next: { $0?.superview }) {
            if let backgroundView = view as? TransitionView {
                alertble = backgroundView.alert
                break
            }
        }
        return alertble
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        alert?.dismiss(completion: completion)
    }
}
