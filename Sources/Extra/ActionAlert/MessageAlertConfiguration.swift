//
//  MessageAlertConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import UIKit

extension MessageAlert {
    
    @MainActor public struct Configuration: @preconcurrency ActionAlertableConfigurable, Sendable  {
        
        public var layoutGuide: AlertLayoutGuide {
            get { actionAlertConfiguration.layoutGuide }
            set { actionAlertConfiguration.layoutGuide = newValue }
        }
        
        public var cornerRadius: CGFloat {
            get { actionAlertConfiguration.cornerRadius }
            set { actionAlertConfiguration.cornerRadius = newValue }
        }
        
        public var makeActionView: (Action.Style) -> (UIView & ActionContent) {
            get { actionAlertConfiguration.makeActionView }
            set { actionAlertConfiguration.makeActionView = newValue }
        }

        public var makeActionLayout: () -> any ActionLayout {
            get { actionAlertConfiguration.makeActionLayout }
            set { actionAlertConfiguration.makeActionLayout = newValue }
        }

        private var actionAlertConfiguration: ActionAlert.Configuration
        
        public var titleConfiguration = TitleConfiguration()
        
        public var messageConfiguration = MessageConfiguration()
        
        init(_ actionAlertConfiguration: ActionAlert.Configuration? = nil) {
            self.actionAlertConfiguration = actionAlertConfiguration ?? ActionAlert.Configuration.global
            self.actionAlertConfiguration.layoutGuide.width = .fixed(270)
        }
        
        public static var global = Configuration()
    }
}

private var defaultTextColor: UIColor {
    return UIColor.label
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

