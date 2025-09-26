//
//  Dismissible.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

@MainActor public protocol Dismissible: AnyObject {

    /// Dismiss the alert.
    /// - Parameter completion: the `completion` callback will invoke after alert dismissed.
    func dismiss(completion: (() -> Void)?)

    func dismiss() async
}

extension Dismissible {

    // Gets the alert in the current UIView or UIViewController.
    var alert: Alert? {
        if let view = self as? UIView {
            for view in sequence(first: view.superview, next: { $0?.superview }) {
                if let responder = view?.next as? AlertContainerController {
                    return responder.alert
                }
            }
            return nil
        }
        if let viewController = self as? UIViewController {
            guard let parent = viewController.parent as? AlertContainerController else {
                return nil
            }
            return parent.alert
        }
        return nil
    }
}

extension Dismissible {

    /// Dismiss the alert.
    /// - Parameter completion: the `completion` callback will invoke after alert dismissed.
    @MainActor public func dismiss(completion: (() -> Void)?) {
        guard let alert = alert else { return }
        alert.dismiss(completion: completion)
    }

    @MainActor public func dismiss() {
        // 注意: 不能使用 dismiss(completion: nil)，需要加上 self 修饰，否则会
        // 直接调用扩展中的 dismiss(completion:) 默认实现，而非子类重写的方法。
        self.dismiss(completion: nil)
    }

    @MainActor public func dismiss() async {
        guard let alert = alert else { return }
        await withUnsafeContinuation({ continuation in
            alert.dismiss { continuation.resume() }
        })
    }
}
