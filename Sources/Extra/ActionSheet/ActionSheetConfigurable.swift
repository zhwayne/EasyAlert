//
//  ActionSheetConfigurable.swift
//
//
//  Created by iya on 2024/4/18.
//

import UIKit

public protocol ActionSheetConfigurable {
    
    var cornerRadius: CGFloat { get set }
    
    var layoutGuide: LayoutGuide { get set }
    
    var actionViewType: (UIView & ActionCustomizable).Type { get set }
    
    var actionLayoutType: ActionLayoutable.Type { get set }
    
    var backgroundViewType: UIView.Type? { get set }
}

extension ActionSheetConfigurable {
    
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
