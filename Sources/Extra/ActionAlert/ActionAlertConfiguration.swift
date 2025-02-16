//
//  ActionAlertConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/5/26.
//

import UIKit

extension ActionAlert {
    
    public struct Configuration: ActionAlertableConfigurable {
        
        public var layoutGuide: LayoutGuide = .init(width: .flexible, height: .flexible)
        
        public var cornerRadius: CGFloat = 13
        
        public var actionViewType: (UIView & ActionCustomizable).Type = ActionView.self
        
        public var actionLayoutType: ActionLayoutable.Type = AlertActionLayout.self
                
        init() { }
        
        public static var global = Configuration()
    }
}
