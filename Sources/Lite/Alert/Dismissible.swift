//
//  Dismissible.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

@MainActor public protocol Fetchable: AnyObject { }

@MainActor public protocol Dismissible : Fetchable {
    
    /// Dismiss the alert.
    /// - Parameter completion: the `completion` callback will invoke after alert dismissed.
    func dismiss(completion: (() -> Void)?)
    
    @available(iOS 13.0, *)
    func dismiss() async
}

extension Fetchable {
    
    // Gets the alert in the current UIView or UIViewController.
    var alert: Alert? {
        if let view = self as? UIView {
            for view in sequence(first: view.superview, next: { $0?.superview }) {
                if let responder = view?.next as? AlertContainerController {
                    return responder.weakAlert
                }
            }
            return nil
        }
        if let viewController = self as? UIViewController {
            guard let parent = viewController.parent as? AlertContainerController else {
                return nil
            }
            return parent.weakAlert
        }
        return nil
    }
}

extension Dismissible {
    
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
