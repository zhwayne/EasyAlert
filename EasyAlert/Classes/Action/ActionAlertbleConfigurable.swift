//
//  ActionAlertbleConfigurable.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/5.
//

import Foundation

public protocol ActionAlertbleConfigurable {
    
    var cornerRadius: CGFloat { get set }
        
    var actionViewType: Action.CustomizedView.Type { get set }
    
    var actionLayout: ActionLayoutable { get set }
    
    var edgeInsets: UIEdgeInsets { get set }
}
