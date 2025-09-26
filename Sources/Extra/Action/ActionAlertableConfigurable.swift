//
//  ActionAlertableConfigurable.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import UIKit

@MainActor public protocol ActionAlertableConfigurable {

    var cornerRadius: CGFloat { get }

    var layoutGuide: LayoutGuide { get }

    var makeActionView: (Action.Style) -> (UIView & ActionContent) { get }

    var makeActionLayout: () -> ActionLayout { get }
}

extension ActionAlertableConfigurable {

    func value(for label: String) -> Any? {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if child.label == label {
                return child.value
            }
        }
        return nil
    }
}
