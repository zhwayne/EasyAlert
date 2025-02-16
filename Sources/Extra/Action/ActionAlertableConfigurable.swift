//
//  ActionAlertableConfigurable.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import UIKit

public protocol ActionAlertableConfigurable {
    
    var cornerRadius: CGFloat { get set }
    
    var layoutGuide: LayoutGuide { get set }
        
    var actionViewType: (UIView & ActionCustomizable).Type { get set }
    
    var actionLayoutType: ActionLayoutable.Type { get set }
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
