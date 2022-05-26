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

fileprivate extension String {
    
    var attributedTitle: NSAttributedString {
        
        typealias Key = NSAttributedString.Key
        let range = NSMakeRange(0, self.count)
        let attributedTitle = NSMutableAttributedString(string: self)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.lineHeightMultiple = 1.1
        attributedTitle.addAttributes([Key.paragraphStyle: paragraphStyle], range: range)
        if #available(iOS 13.0, *) {
            attributedTitle.addAttributes([Key.font: UIColor.label], range: range)
        } else {
            // Fallback on earlier versions
            let color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            attributedTitle.addAttributes([Key.font: color], range: range)
        }
        
        let font = UIFont.systemFont(ofSize: 18, weight: .medium)
        attributedTitle.addAttributes([Key.font: font], range: range)
        
        return NSAttributedString(attributedString: attributedTitle)
    }
    
    var attributedMessage: NSAttributedString {
        
        let range = NSRange(location: 0, length: self.count)
        typealias Key = NSAttributedString.Key
        let attributedString = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.lineHeightMultiple = 1.1
        if #available(iOS 13.0, *) {
            attributedString.setAttributes([
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle,
            ], range: range)
        } else {
            // Fallback on earlier versions
            attributedString.setAttributes([
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.gray,
                .paragraphStyle: paragraphStyle,
            ], range: range)
        }
        
        return NSAttributedString(attributedString: attributedString)
    }
}
