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
        
        public var cancelSpacing: CGFloat = 8
        
        public var actionViewType: (UIView & ActionCustomizable).Type = ActionView.self
        
        public var actionLayoutType: ActionLayoutable.Type = SheetActionLayout.self
                
        public init() { }
        
        public static var global = Configuration()
    }
}
