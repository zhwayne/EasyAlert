//
//  ActionAlertConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/5/26.
//

import UIKit

extension ActionAlert {

    @MainActor public struct Configuration: @preconcurrency ActionAlertableConfigurable, Sendable {

        public var layoutGuide: LayoutGuide = LayoutGuide(width: .flexible, height: .flexible)
        
        public var cornerRadius: CGFloat = 13
                
        public var makeActionView: (Action.Style) -> (UIView & ActionCustomizable) = { style in
            ActionView(style: style)
        }
        
        public var makeActionLayout: () -> any ActionLayout = {
            AlertActionLayout()
        }
                        
        init() { }
        
        public static var global = Configuration()
    }
}
