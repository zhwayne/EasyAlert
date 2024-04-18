//
//  ActionAlertConfigurable.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import UIKit

public protocol ActionAlertConfigurable {
    
    var cornerRadius: CGFloat { get set }
    
    var contentInsets: UIEdgeInsets { get set }
        
    var actionViewType: (UIView & ActionCustomizable).Type { get set }
    
    var actionLayoutType: ActionLayoutable.Type { get set }
    
    var backgroundViewType: UIView.Type? { get set }
}
