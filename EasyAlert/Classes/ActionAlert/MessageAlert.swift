//
//  MessageAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/8/2.
//

import UIKit
import SnapKit

public final class MessageAlert: ActionAlert {
    
    public var title: String? {
        alertCustomView.titleView.titleLabel.text
    }
    
    private final class MessageView: UIView, AlertCustomable {
        
        fileprivate let label = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            if #available(iOS 13.0, *) {
                backgroundColor = .systemBackground
            } else {
                backgroundColor = .white
            }
            label.numberOfLines = 0
            addSubview(label)
            
            label.snp.makeConstraints { maker in
                maker.edges.equalTo(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    @available(*, unavailable)
    public required init(title: NSAttributedString?, customView: ActionAlert.CustomizedView) {
        super.init(title: title, customView: customView)
    }
    
    public convenience init(title: String?, message: String?) {
        let attributedTitle = title?.attributedTitle
        let attributedMessage = message?.attributedMessage
        self.init(title: attributedTitle, message: attributedMessage)
    }
    
    public required init(title: NSAttributedString?, message: NSAttributedString?) {
        let messageView = MessageView()
        messageView.label.attributedText = message
        messageView.isHidden = message == nil
        super.init(title: title, customView: messageView)
    }
    
    public override func willShow() {
        super.willShow()
        alertCustomView.contentStackView.insertArrangedSubview(alertCustomView.titleView, at: 0)
    }
}

extension String {
    
    var attributedMessage: NSAttributedString {
        
        let range = NSRange(location: 0, length: self.count)
        typealias Key = NSAttributedString.Key
        let attributedString = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.lineHeightMultiple = 1.2
        if #available(iOS 13.0, *) {
            attributedString.setAttributes([
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: paragraphStyle,
            ], range: range)
        } else {
            // Fallback on earlier versions
            attributedString.setAttributes([
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.gray,
                .paragraphStyle: paragraphStyle,
            ], range: range)
        }
        
        return NSAttributedString(attributedString: attributedString)
    }
}
