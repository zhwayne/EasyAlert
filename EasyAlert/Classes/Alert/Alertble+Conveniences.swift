//
//  Alertble+Conveniences.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import Foundation

public extension UIView {
    
    func presentAlertble(_ alertble: Alertble) {
        alertble.show(on: self)
    }
    
    // TODO: 也许应该放开查询 `UIView` 中全部 alert 的 API？
    // var visiableAlert: Alertble? { alerts.last }
}

public func presentAlertble(_ alertble: Alertble) {
    alertble.show(on: nil)
}
