//
//  Alertable.swift
//  EasyAlert
//
//  Created by iya on 2021/7/27.
//

import UIKit

@MainActor public protocol AlertHosting: AnyObject { }

extension UIView: AlertHosting { }

extension UIViewController: AlertHosting { }

@MainActor public protocol Alertable : Dismissible {
    
    /// A value that marks whether an alert is being displayed.
    var isActive: Bool { get }
    
    /// Show alert in the container.
    /// - Parameter container: An instance of a `UIView` or `UIViewController` that implements the
    /// `AlertHosting`.
    func show(in container: AlertHosting?)
}

extension AlertHosting {
    
    // MARK: - Associated Objects
    
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
    
    /// Attach an alert to the view.
    /// - Parameter alert: The alert to be attached.
    func attach(alert: Alertable) {
        if alerts.contains(where: { alert === $0 }) {
            return
        }
        alerts.append(alert)
    }
    
    /// Detach an alert from the view.
    /// - Parameter alert: The alert to be detached.
    func detach(alert: Alertable) {
        if let index = alerts.lastIndex(where: { $0 === alert }) {
            alerts.remove(at: index)
        }
    }
}

@MainActor
fileprivate struct AssociatedKey {
    static var alerts = malloc(1)!
}
