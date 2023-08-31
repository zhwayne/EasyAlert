//
//  MessageAlertTitleAndMessage.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

extension MessageAlert {
    
    func text(for title: Title?) -> NSAttributedString? {
        if let text = title as? String {
            return attributedTitle(text)
        }
        if #available(iOS 15, *), let text = title as? AttributedString {
            return NSAttributedString(text)
        }
        return title as? NSAttributedString
    }
    
    func text(for message: Message?) -> NSAttributedString? {
        if let text = message as? String {
            return attributedMessage(text)
        }
        if #available(iOS 15, *), let text = message as? AttributedString {
            return NSAttributedString(text)
        }
        return message as? NSAttributedString
    }
}

extension MessageAlert {
    
    private var titleAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let titleConfiguration = titleConfiguration
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        paragraphStyle.alignment = titleConfiguration.alignment
        attributes[.font] = titleConfiguration.font
        attributes[.foregroundColor] = titleConfiguration.color
        attributes[.paragraphStyle] = paragraphStyle.copy()
        return attributes
    }
    
    private var messageAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let messageConfiguration = messageConfiguration
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.05
        paragraphStyle.alignment = messageConfiguration.alignment
        attributes[.font] = messageConfiguration.font
        attributes[.foregroundColor] = messageConfiguration.color
        attributes[.paragraphStyle] = paragraphStyle.copy()
        return attributes
    }
    
    func attributedTitle(_ title: String) -> NSAttributedString {
        let range = NSMakeRange(0, title.count)
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttributes(titleAttributes, range: range)
        return NSAttributedString(attributedString: attributedTitle)
    }
    
    func attributedMessage(_ message: String) -> NSAttributedString {
        let range = NSMakeRange(0, message.count)
        let attributedMessage = NSMutableAttributedString(string: message)
        attributedMessage.addAttributes(messageAttributes, range: range)
        return NSAttributedString(attributedString: attributedMessage)
    }
}
