//
//  AlertDismissible.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import Foundation

public protocol AlertFetchable: AnyObject { }

public protocol AlertDismissible : AlertFetchable {
    
    /// 关掉 alert。
    /// - Parameter completion: 完成回调。
    func dismiss(completion: (() -> Void)?)
    
    @available(iOS 13.0, *)
    @MainActor func dismissAsync() async
}

extension AlertFetchable {
    
    // 获取和 view 关联的 alert。
    var alert: Alert? {
        if let view = self as? UIView {
            for view in sequence(first: view.superview, next: { $0?.superview }) {
                if let responder = view?.next as? AlertViewController {
                    return responder.weakAlert
                }
            }
            return nil
        }
        if let viewController = self as? UIViewController {
            guard let parent = viewController.parent as? AlertViewController else {
                return nil
            }
            return parent.weakAlert
        }
        return nil
    }
}

extension AlertDismissible {
    
    /// 关掉 alert。
    /// - Parameter completion: 完成回调。
    public func dismiss(completion: (() -> Void)? = nil) {
        guard let alert = alert else { return }
        alert.dismiss(completion: completion)
    }
    
    @available(iOS 13.0, *)
    @MainActor public func dismissAsync() async {
        guard let alert = alert else { return }
        await withUnsafeContinuation({ continuation in
            alert.dismiss { continuation.resume() }
        })
    }
}
