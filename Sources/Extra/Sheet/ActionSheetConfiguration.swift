//
//  ActionSheetConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/12/6.
//

import UIKit

extension ActionSheet {
    
    @MainActor public struct Configuration: @preconcurrency ActionAlertableConfigurable, Sendable {

        public var layoutGuide: AlertLayoutGuide = .init(
            width: .multiplied(by: 1, maxWidth: 414),
            height: .flexible,
            contentInsets: UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
        )

        public var cornerRadius: CGFloat = 13
        
        public var cancelSpacing: CGFloat = 8
        
        public var makeActionView: (Action.Style) -> (UIView & ActionContent) = { style in
            ActionView(style: style)
        }
        
        public var makeActionLayout: () -> any ActionLayout = {
            SheetActionLayout()
        }
                        
        init() { }
        
        public static var global = Configuration()
    }
}
