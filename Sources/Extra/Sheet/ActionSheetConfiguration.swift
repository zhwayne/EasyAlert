//
//  ActionSheetConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/12/6.
//

import UIKit

extension ActionSheet {
    
    public struct Configuration: ActionAlertbleConfigurable {
        
        public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)

        public var cornerRadius: CGFloat = 13
        
        public var cancelSpacing: CGFloat = 8
        
        public var actionViewType: (UIView & ActionCustomizable).Type = ActionView.self
        
        public var actionLayoutType: ActionLayoutable.Type = SheetActionLayout.self
                
        init() { }
        
        public static var global = Configuration()
    }
}
