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

extension MessageAlert {
    
    func text(for title: Title?) -> NSAttributedString? {
        if let text = title as? String {
            return attributedTitle(text)
        }
        return title as? NSAttributedString
    }
    
    func text(for message: Message?) -> NSAttributedString? {
        if let text = message as? String {
            return attributedTitle(text)
        }
        return message as? NSAttributedString
    }
}

extension MessageAlert {
    
    var titleAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        paragraphStyle.alignment = titleConfig.alignment
        attributes[.font] = titleConfig.font
        attributes[.foregroundColor] = titleConfig.color
        attributes[.paragraphStyle] = paragraphStyle
        return attributes
    }
    
    var messageAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.05
        paragraphStyle.alignment = messageConfig.alignment
        attributes[.font] = messageConfig.font
        attributes[.foregroundColor] = messageConfig.color
        attributes[.paragraphStyle] = paragraphStyle
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
