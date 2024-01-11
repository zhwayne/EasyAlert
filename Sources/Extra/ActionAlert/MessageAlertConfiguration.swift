//
//  MessageAlertConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import UIKit

extension MessageAlert {
    
    public struct Configuration: ActionAlertbleConfigurable {
        
        public var contentInsets: UIEdgeInsets {
            get { actionAlertConfiguration.contentInsets }
            set { actionAlertConfiguration.contentInsets = newValue }
        }
        
        public var cornerRadius: CGFloat {
            get { actionAlertConfiguration.cornerRadius }
            set { actionAlertConfiguration.cornerRadius = newValue }
        }
        
        public var actionViewType: (UIView & ActionCustomizable).Type {
            get { actionAlertConfiguration.actionViewType }
            set { actionAlertConfiguration.actionViewType = newValue }
        }
        
        public var actionLayoutType: ActionLayoutable.Type {
            get { actionAlertConfiguration.actionLayoutType }
            set { actionAlertConfiguration.actionLayoutType = newValue }
        }
                
        private var actionAlertConfiguration: ActionAlert.Configuration
        
        public var titleConfiguration = TitleConfiguration()
        
        public var messageConfiguration = MessageConfiguration()
        
        init(_ actionAlertConfiguration: ActionAlert.Configuration? = nil) {
            self.actionAlertConfiguration = actionAlertConfiguration ?? ActionAlert.Configuration.global
        }
        
        public static var global = Configuration()
    }
}

private var defaultTextColor: UIColor {
    if #available(iOS 13.0, *) {
        return UIColor.label
    } else {
        return UIColor(white: 0.33, alpha: 0.6)
    }
}

extension MessageAlert {
    
    public struct TitleConfiguration {
        
        public var alignment: NSTextAlignment = .center
        
        public var font: UIFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        public var color: UIColor = defaultTextColor
        
        public init() {}
    }
}


extension MessageAlert {
    
    public struct MessageConfiguration {
        
        public var alignment: NSTextAlignment = .center
        
        public var font: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        public var color: UIColor = defaultTextColor
        
        public init() {}
    }
}

