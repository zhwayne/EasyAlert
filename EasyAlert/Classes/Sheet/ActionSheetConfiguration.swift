//
//  ActionSheetConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/12/6.
//

import Foundation

extension ActionSheet {
    
    public struct Configuration: ActionAlertbleConfigurable {
        
        public var cornerRadius: CGFloat = 13
        
        public var actionViewType: Action.CustomizedView.Type = ActionView.self
        
        public var actionLayout: ActionLayoutable = SheetActionLayout()
                
        public init() { }
        
        public static var global = Configuration()
    }
}
