//
//  UIView+EasyAlert.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

extension UIView {
    
    // MARK: - Associated Objects
    
    private var alerts: [Alertble] {
        get {
            if let alerts = objc_getAssociatedObject(self, &AssociatedKey.alerts) as? [Alertble] {
                return alerts
            }
            objc_setAssociatedObject(self, &AssociatedKey.alerts, [], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.alerts, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
    static var alerts = "alerts"
}
