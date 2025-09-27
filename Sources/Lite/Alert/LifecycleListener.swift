//
//  LifecycleListener.swift
//  EasyAlert
//
//  Created by iya on 2022/5/28.
//

import Foundation

/// A protocol that defines methods for responding to alert lifecycle events.
///
/// `LifecycleListener` provides a way to observe and respond to different phases
/// of an alert's lifecycle, including show and dismiss events. This is useful for
/// performing setup, cleanup, or analytics tracking when alerts appear or disappear.
@MainActor public protocol LifecycleListener {

    /// Called before the alert is shown.
    ///
    /// This method is called just before the alert's presentation animation begins.
    /// Use this to perform any setup that should happen before the alert appears.
    func willShow()

    /// Called after the alert is shown.
    ///
    /// This method is called after the alert's presentation animation completes.
    /// Use this to perform any actions that should happen after the alert is fully visible.
    func didShow()

    /// Called before the alert is dismissed.
    ///
    /// This method is called just before the alert's dismissal animation begins.
    /// Use this to perform any cleanup that should happen before the alert disappears.
    func willDismiss()

    /// Called after the alert is dismissed.
    ///
    /// This method is called after the alert's dismissal animation completes.
    /// Use this to perform any final actions after the alert is no longer visible.
    func didDismiss()
}

extension LifecycleListener {

    /// Default implementation that does nothing.
    public func willShow() { }

    /// Default implementation that does nothing.
    public func didShow() { }

    /// Default implementation that does nothing.
    public func willDismiss() { }

    /// Default implementation that does nothing.
    public func didDismiss() { }
}

/// A concrete implementation of `LifecycleListener` that uses closures for event handling.
///
/// `LifecycleCallback` provides a convenient way to create lifecycle listeners
/// using closures instead of implementing the protocol directly. This is useful
/// for simple cases where you just need to execute code at specific lifecycle events.
public struct LifecycleCallback: LifecycleListener {

    /// A closure type for handling lifecycle events.
    public typealias LifecycleHandler = () -> Void

    /// The closure to call when the alert is about to show.
    let willShowHandler: LifecycleHandler?

    /// The closure to call when the alert has finished showing.
    let didShowHandler: LifecycleHandler?

    /// The closure to call when the alert is about to dismiss.
    let willDismissHandler: LifecycleHandler?

    /// The closure to call when the alert has finished dismissing.
    let didDismissHandler: LifecycleHandler?

    /// Creates a new lifecycle callback with the specified handlers.
    ///
    /// - Parameters:
    ///   - willShow: A closure to call before the alert is shown.
    ///   - didShow: A closure to call after the alert is shown.
    ///   - willDismiss: A closure to call before the alert is dismissed.
    ///   - didDismiss: A closure to call after the alert is dismissed.
    public init(willShow: LifecycleHandler? = nil,
                didShow: LifecycleHandler? = nil,
                willDismiss: LifecycleHandler? = nil,
                didDismiss: LifecycleHandler? = nil) {
        self.willShowHandler = willShow
        self.didShowHandler = didShow
        self.willDismissHandler = willDismiss
        self.didDismissHandler = didDismiss
    }

    /// Calls the will show handler if it exists.
    public func willShow() {
        willShowHandler?()
    }

    /// Calls the did show handler if it exists.
    public func didShow() {
        didShowHandler?()
    }

    /// Calls the will dismiss handler if it exists.
    public func willDismiss() {
        willDismissHandler?()
    }

    /// Calls the did dismiss handler if it exists.
    public func didDismiss() {
        didDismissHandler?()
    }
}
