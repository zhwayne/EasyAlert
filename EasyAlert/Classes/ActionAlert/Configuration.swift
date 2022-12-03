//
//  ActionAlertConfiguration.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/5/26.
//

import Foundation

public protocol ActionAlertConfiguration {
    
    var cornerRadius: CGFloat { get set }
    
    var actionViewType: Action.CustomizedView.Type { get set }
    
    var actionLayout: ActionLayoutable { get set }
}

public extension ActionAlert {
    
    struct Configuration: ActionAlertConfiguration {
        
        public var cornerRadius: CGFloat = 13
        
        public var actionViewType: Action.CustomizedView.Type = ActionView.self
        
        public var actionLayout: ActionLayoutable = ActionLayout()
        
        public init() {}
        
        public static var global = Configuration()
    }
}
