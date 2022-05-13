//
//  UIView+EasyAlert.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

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
