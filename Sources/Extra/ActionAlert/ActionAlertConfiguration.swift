//
//  ActionAlertConfiguration.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/5/26.
//

import UIKit

extension ActionAlert {
    
    public struct Configuration: ActionAlertbleConfigurable {
        
        public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        public var cornerRadius: CGFloat = 13
        
        public var actionViewType: (UIView & ActionCustomizable).Type = ActionView.self
        
        public var actionLayoutType: ActionLayoutable.Type = AlertActionLayout.self
                
        init() { }
        
        public static var global = Configuration()
    }
}
