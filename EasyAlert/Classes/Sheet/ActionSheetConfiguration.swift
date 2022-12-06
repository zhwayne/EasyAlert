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
        
        public var actionLayout: ActionLayoutable = AlertActionLayout()
        
        public var titleConfiguration = TitleConfiguration()
        
        public var messageConfiguration = MessageConfiguration()
        
        public init() {}
        
        public static var globalConfiguration = ActionSheet.Configuration()
    }
}

private var defaultTextColor: UIColor {
    if #available(iOS 13.0, *) {
        return UIColor.label
    } else {
        return UIColor(white: 0.33, alpha: 0.6)
    }
}

extension ActionSheet {
    
    public struct TitleConfiguration {
        
        public var alignment: NSTextAlignment = .center
        
        public var font: UIFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
        
        public var color: UIColor = defaultTextColor
        
        public init() {}
    }
}


extension ActionSheet {
    
    public struct MessageConfiguration {
        
        public var alignment: NSTextAlignment = .center
        
        public var font: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        public var color: UIColor = defaultTextColor
        
        public init() {}
    }
}

