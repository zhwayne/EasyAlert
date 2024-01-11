//
//  ActionAlertbleConfigurable.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/5.
//

import UIKit

public protocol ActionAlertbleConfigurable {
    
    var cornerRadius: CGFloat { get set }
    
    var contentInsets: UIEdgeInsets { get set }
        
    var actionViewType: (UIView & ActionCustomizable).Type { get set }
    
    var actionLayoutType: ActionLayoutable.Type { get set }
}

extension ActionAlertbleConfigurable {
    
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
