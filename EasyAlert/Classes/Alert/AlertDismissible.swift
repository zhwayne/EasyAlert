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

extension AlertFetchable where Self : UIView {
    
    /// 获取和 view 关联的 alert。
    var alert: Alertble? {
        for view in sequence(first: superview, next: { $0?.superview }) {
            if let responder = view?.next as? AlertViewController {
                return responder.weakAlert
            }
        }
        return nil
    }
}

extension AlertFetchable where Self : UIViewController {
    
    /// 获取和 view 关联的 alert。
    var alert: Alertble? {
        guard let parent = self.parent as? AlertViewController else {
            return nil
        }
        return parent.weakAlert
    }
}

extension AlertDismissible {
    
    /// 关掉 alert。
    /// - Parameter completion: 完成回调。
    public func dismiss(completion: (() -> Void)? = nil) where Self: UIView {
        alert?.dismiss(completion: completion)
    }
    
    public func dismiss(completion: (() -> Void)? = nil) where Self: UIViewController {
        alert?.dismiss(completion: completion)
    }
    
    @available(iOS 13.0, *)
    @MainActor public func dismissAsync() async {
        await withUnsafeContinuation({ continuation in
            dismiss { continuation.resume() }
        })
    }
}
