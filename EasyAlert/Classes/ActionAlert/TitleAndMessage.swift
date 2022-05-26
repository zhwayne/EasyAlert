//
//  TitleAndMessage.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import Foundation

public protocol Title { }
public protocol Message { }

extension String: Title, Message { }
extension NSAttributedString: Title, Message { }

extension Title {
    
    var title: NSAttributedString {
        if let text = self as? String {
            return text.attributedTitle
        }
        return self as! NSAttributedString
    }
}

extension Message {
    
    var message: NSAttributedString {
        if let text = self as? String {
            return text.attributedMessage
        }
        return self as! NSAttributedString
    }
}

extension ActionAlert {
    
    static var titleAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        attributes[.font] = ActionAlert.configuration.titleFont
        attributes[.foregroundColor] = ActionAlert.configuration.color
        return attributes
    }
}

extension MessageAlert {
    
    static var messageAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        attributes[.font] = MessageAlert.messageConfiguration.messageFont
        attributes[.foregroundColor] = MessageAlert.messageConfiguration.color
        return attributes
    }
}

fileprivate extension String {
    
    var attributedTitle: NSAttributedString {
        let range = NSMakeRange(0, self.count)
        let attributedTitle = NSMutableAttributedString(string: self)
        attributedTitle.addAttributes(ActionAlert.titleAttributes, range: range)
        return NSAttributedString(attributedString: attributedTitle)
    }
    
    var attributedMessage: NSAttributedString {
        let range = NSMakeRange(0, self.count)
        let attributedMessage = NSMutableAttributedString(string: self)
        attributedMessage.addAttributes(MessageAlert.messageAttributes, range: range)
        return NSAttributedString(attributedString: attributedMessage)
    }
}
