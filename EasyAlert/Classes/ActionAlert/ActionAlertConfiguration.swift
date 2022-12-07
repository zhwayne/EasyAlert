//
//  ActionAlertConfiguration.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/5/26.
//

import Foundation

extension ActionAlert {
    
    public struct Configuration: ActionAlertbleConfigurable {
        
        public var cornerRadius: CGFloat = 13
        
        public var actionViewType: Action.CustomizedView.Type = ActionView.self
        
        public var actionLayout: ActionLayoutable = AlertActionLayout()
        
        // Unused for now.
        public var edgeInsets: UIEdgeInsets = .zero
        
        public init() { }
        
        public static var global = Configuration()
    }
}
