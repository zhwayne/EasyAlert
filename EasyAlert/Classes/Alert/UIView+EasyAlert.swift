//
//  UIView+EasyAlert.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

extension UIView {
    
    public func presentAlert(_ alert: Alertble) {
        if let alert = alert as? Alert {
            alert.show(in: self)
        }
    }
    
    // TODO: 也许应该放开查询 `UIView` 中全部 alert 的 API？
    // public var visiableAlert: Alertble? { alerts.last }
}


extension UIView {
    
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
    
    func attach(alert: Alertble) {
        if alerts.contains(where: { alert === $0 }) {
            return
        }
        alerts.append(alert)
    }
    
    func detach(alert: Alertble) {
        if let index = alerts.lastIndex(where: { $0 === alert }) {
            alerts.remove(at: index)
        }
    }
}

fileprivate struct AssociatedKey {
    static var alerts = "alerts"
}

