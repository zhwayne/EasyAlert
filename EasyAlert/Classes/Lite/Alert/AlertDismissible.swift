//
//  AlertDismissible.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import Foundation

@MainActor public protocol AlertFetchable: AnyObject { }

@MainActor public protocol AlertDismissible : AlertFetchable {
    
    /// Dismiss the alert.
    /// - Parameter completion: the `completion` callback will invoke after alert dismissed.
    func dismiss(completion: (() -> Void)?)
    
    @available(iOS 13.0, *)
    func dismiss() async
}

extension AlertFetchable {
    
    // Gets the alert in the current UIView or UIViewController.
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
    
    /// Dismiss the alert.
    /// - Parameter completion: the `completion` callback will invoke after alert dismissed.
    @MainActor public func dismiss(completion: (() -> Void)? = nil) {
        guard let alert = alert else { return }
        alert.dismiss(completion: completion)
    }
    
    @available(iOS 13.0, *)
    @MainActor public func dismiss() async {
        guard let alert = alert else { return }
        await withUnsafeContinuation({ continuation in
            alert.dismiss { continuation.resume() }
        })
    }
}
