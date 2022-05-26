//
//  ActionAlertConfiguration.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/5/26.
//

import Foundation

public extension ActionAlert {
    
    struct Configuration {
        
        public var cornerRadius: CGFloat = 13
        
        public var actionViewType: Action.CustomizedView.Type = ActionView.self
        
        public var actionLayout: ActionLayoutable = ActionLayout()
        
        public var titleAlignment: NSTextAlignment = .center
        
        public var titleFont: UIFont = UIFont.boldSystemFont(ofSize: 17.5)
        
        public lazy var color: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            }
        }()
    }
}

public extension MessageAlert {
    
    struct Configuration {
        
        public var messageAlignment: NSTextAlignment = .center
        
        public var messageFont: UIFont = UIFont.systemFont(ofSize: 13)
        
        public lazy var color: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            }
        }()
    }
}
