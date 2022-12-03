//
//  MessageAlertConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/5/27.
//

import Foundation

private var defaultTextColor: UIColor {
    if #available(iOS 13.0, *) {
        return UIColor.label
    } else {
        return UIColor(white: 0.33, alpha: 0.6)
    }
}

public protocol MessageAlertConfiguration: ActionAlertConfiguration {
    
    var titleConfiguration: MessageAlert.TitleConfiguration { get set }
   
    var messageConfiguration: MessageAlert.MessageConfiguration { get set }
}


public extension MessageAlert {
    
    struct Configuration: MessageAlertConfiguration {
        
        public var cornerRadius: CGFloat {
            get { actionAlertConfiguration.cornerRadius }
            set { actionAlertConfiguration.cornerRadius = newValue }
        }
        
        public var actionViewType: Action.CustomizedView.Type {
            get { actionAlertConfiguration.actionViewType }
            set { actionAlertConfiguration.actionViewType = newValue }
        }
        
        public var actionLayout: ActionLayoutable {
            get { actionAlertConfiguration.actionLayout }
            set { actionAlertConfiguration.actionLayout = newValue }
        }
        
        private var actionAlertConfiguration = ActionAlert.Configuration()
        
        public var titleConfiguration = TitleConfiguration()
        
        public var messageConfiguration = MessageConfiguration()
        
        public init() {}
        
        public static var global = Configuration()
    }
}

public extension MessageAlert {
    
    struct TitleConfiguration {
        
        public var alignment: NSTextAlignment = .center
        
        public var font: UIFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        public var color: UIColor = defaultTextColor
        
        public init() {}
    }
    
    
    struct MessageConfiguration {

        public var alignment: NSTextAlignment = .center

        public var font: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)

        public var color: UIColor = defaultTextColor
        
        public init() {}
    }
}
