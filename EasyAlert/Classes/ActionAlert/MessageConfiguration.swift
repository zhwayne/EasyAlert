//
//  MessageAlertConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/5/27.
//

import Foundation

extension MessageAlert {

    public static var titleConfiguration: TitleConfiguration {
        TitleConfiguration()
    }
    
    public static var messageConfiguration: MessageConfiguration {
        MessageConfiguration()
    }
}


public extension MessageAlert {
    
    struct TitleConfiguration {
        
        public var alignment: NSTextAlignment = .center
        
        public var font: UIFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        public var color: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return UIColor(white: 0.33, alpha: 0.6)
            }
        }()
    }
    
    
    struct MessageConfiguration {

        public var alignment: NSTextAlignment = .center

        public var font: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)

        public var color: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return UIColor(white: 0.33, alpha: 0.6)
            }
        }()
    }
}
