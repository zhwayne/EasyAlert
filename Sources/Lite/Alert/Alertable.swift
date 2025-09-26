//
//  Alertable.swift
//  EasyAlert
//
//  Created by iya on 2021/7/27.
//

import UIKit

/// A protocol that defines objects capable of hosting alerts.
///
/// Objects conforming to `AlertHosting` can display and manage alert presentations.
@MainActor public protocol AlertHosting: AnyObject { }

extension UIView: AlertHosting { }

extension UIViewController: AlertHosting { }

/// A protocol that defines the basic interface for alert objects.
///
/// `Alertable` provides the core functionality for displaying and managing alerts,
/// including showing alerts in hosting containers and tracking their active state.
@MainActor public protocol Alertable: Dismissible {

    /// A Boolean value indicating whether the alert is currently active and visible.
    var isActive: Bool { get }

    /// Shows the alert in the specified hosting container.
    ///
    /// - Parameter container: An instance of a `UIView` or `UIViewController` that implements the `AlertHosting` protocol.
    func show(in container: AlertHosting?)
}

extension AlertHosting {

    // MARK: - Associated Objects

    /// The array of alerts currently attached to this hosting object.
    private var alerts: [Alertable] {
        get {
            if let alerts = objc_getAssociatedObject(self, AssociatedKey.alerts) as? [Alertable] {
                return alerts
            }
            objc_setAssociatedObject(self, AssociatedKey.alerts, [] as [Alertable], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return []
        }
        set {
            objc_setAssociatedObject(self, AssociatedKey.alerts, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - Public Methods

    /// Attaches an alert to this hosting object.
    ///
    /// - Parameter alert: The alert to be attached.
    func attach(alert: Alertable) {
        if alerts.contains(where: { alert === $0 }) {
            return
        }
        alerts.append(alert)
    }

    /// Detaches an alert from this hosting object.
    ///
    /// - Parameter alert: The alert to be detached.
    func detach(alert: Alertable) {
        if let index = alerts.lastIndex(where: { $0 === alert }) {
            alerts.remove(at: index)
        }
    }
}

@MainActor
fileprivate struct AssociatedKey {
    static var alerts = "EasyAlert.alerts"
}
