//
//  ActionAlertConfiguration.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/5/26.
//

import Foundation

extension ActionAlert {
    
    public static var config = Configuration()
}

public extension ActionAlert {
    
    struct Configuration {
        
        public var cornerRadius: CGFloat = 13
        
        public var actionViewType: Action.CustomizedView.Type = ActionView.self
        
        public var actionLayout: ActionLayoutable = ActionLayout()
        
    }
}
