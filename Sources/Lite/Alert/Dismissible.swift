//
//  Dismissible.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

/// A protocol that defines objects capable of being dismissed.
///
/// `Dismissible` provides a common interface for dismissing alerts and other modal presentations.
/// Objects conforming to this protocol can be dismissed with optional completion handlers.
@MainActor public protocol Dismissible: AnyObject {

    /// Dismisses the object with an optional completion handler.
    ///
    /// - Parameter completion: A closure to execute when the dismissal animation completes.
    func dismiss(completion: (() -> Void)?)

    /// Dismisses the object asynchronously.
    ///
    /// - Returns: An async operation that completes when the object is fully dismissed.
    func dismiss() async
}

extension Dismissible {

    /// Gets the alert associated with the current view or view controller.
    ///
    /// This property traverses the view hierarchy to find the containing alert.
    /// - Returns: The associated alert, or `nil` if no alert is found.
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

    /// Dismisses the associated alert with an optional completion handler.
    ///
    /// - Parameter completion: A closure to execute when the dismissal animation completes.
    @MainActor public func dismiss(completion: (() -> Void)?) {
        guard let alert = alert else { return }
        alert.dismiss(completion: completion)
    }

    /// Dismisses the associated alert without a completion handler.
    ///
    /// Note: This method uses `self.dismiss(completion: nil)` to ensure the correct
    /// implementation is called, avoiding potential issues with method resolution.
    @MainActor public func dismiss() {
        // Note: Cannot use dismiss(completion: nil) directly, must use self modifier
        // to avoid calling the extension's default implementation instead of the subclass override.
        self.dismiss(completion: nil)
    }

    /// Dismisses the associated alert asynchronously.
    ///
    /// - Returns: An async operation that completes when the alert is fully dismissed.
    @MainActor public func dismiss() async {
        guard let alert = alert else { return }
        await withUnsafeContinuation({ continuation in
            alert.dismiss { continuation.resume() }
        })
    }
}
