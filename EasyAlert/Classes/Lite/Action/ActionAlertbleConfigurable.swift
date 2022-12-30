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
    
    var actionLayoutType: ActionLayoutable.Type { get set }
}
