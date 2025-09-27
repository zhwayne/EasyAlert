//
//  AlertWindow.swift
//  EasyAlert
//
//  Created by iya on 2022/12/23.
//

import UIKit

/// A specialized window used for displaying alerts when no specific hosting view is available.
///
/// `AlertWindow` extends `UIWindow` to provide custom hit testing behavior that allows
/// alerts to be displayed in their own window context. This is useful when you need
/// to show alerts that are not tied to a specific view controller or view hierarchy.
///
/// The window automatically filters out hits to itself and its root view controller's view,
/// ensuring that touch events are properly handled by the alert content.
internal class AlertWindow: UIWindow {

    /// Returns the view that should receive touch events for the specified point.
    ///
    /// This method overrides the default hit testing behavior to ensure that touches
    /// on the window itself or its root view controller's view are not handled,
    /// allowing the alert content to receive touch events properly.
    ///
    /// - Parameters:
    ///   - point: The point to test for hit testing.
    ///   - event: The event that triggered the hit test.
    /// - Returns: The view that should receive the touch event, or `nil` if the touch should be ignored.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view === self || view === rootViewController?.view { return nil }
        return view
    }
}
