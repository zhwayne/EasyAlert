//
//  Alertble.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

@MainActor public protocol AlertContainerable: AnyObject { }

extension UIView: AlertContainerable { }

extension UIViewController: AlertContainerable { }

@MainActor public protocol Alertble : AlertDismissible {
    
    /// A value that marks whether an alert is being displayed.
    var isShowing: Bool { get }
    
    /// Show alert in the container.
    /// - Parameter container: An instance of a `UIView` or `UIViewController` that implements the
    /// `AlertContainerable`.
    func show(in container: AlertContainerable?)
}

extension AlertContainerable {
    
    // MARK: - Associated Objects
    
    private var alerts: [Alertble] {
        get {
            if let alerts = objc_getAssociatedObject(self, AssociatedKey.alerts) as? [Alertble] {
                return alerts
            }
            objc_setAssociatedObject(self, AssociatedKey.alerts, [] as [Alertble], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return []
        }
        set {
            objc_setAssociatedObject(self, AssociatedKey.alerts, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Public Methods
    
    /// Attach an alert to the view.
    /// - Parameter alert: The alert to be attached.
    func attach(alert: Alertble) {
        if alerts.contains(where: { alert === $0 }) {
            return
        }
        alerts.append(alert)
    }
    
    /// Detach an alert from the view.
    /// - Parameter alert: The alert to be detached.
    func detach(alert: Alertble) {
        if let index = alerts.lastIndex(where: { $0 === alert }) {
            alerts.remove(at: index)
        }
    }
}

fileprivate struct AssociatedKey {
    static var alerts = malloc(1)!
}
