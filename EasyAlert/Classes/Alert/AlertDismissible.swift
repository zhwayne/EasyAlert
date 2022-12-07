//
//  AlertDismissible.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import Foundation

public protocol AlertDismissible : AnyObject {
    
    /// 关掉 alert。
    /// - Parameter completion: 完成回调。
    @MainActor func dismiss(completion: (() -> Void)?)
    
    @available(iOS 13.0, *)
    @MainActor func dismiss() async
}

public extension AlertDismissible where Self: UIView {
    
    /// 获取和 view 关联的 alert。
    private var alert: Alertble? {
        var alertble: Alertble?
        for view in sequence(first: superview, next: { $0?.superview }) {
            if let backgroundView = view as? DimmingKnockoutBackdropView {
                alertble = backgroundView.alert
                break
            }
        }
        return alertble
    }
    
    /// 关掉 alert。
    /// - Parameter completion: 完成回调。
    @MainActor func dismiss(completion: (() -> Void)? = nil) {
        alert?.dismiss(completion: completion)
    }
    
    @available(iOS 13.0, *)
    @MainActor func dismiss() async {
        await withUnsafeContinuation({ continuation in
            dismiss { continuation.resume() }
        })
    }
}
