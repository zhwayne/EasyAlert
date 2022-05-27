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
        contentView.titleLabel.attributedText?.string
    }
    
    public var message: String? {
        contentView.messageLabel.attributedText?.string
    }
    
    private final class ContentView: UIView, AlertCustomizable {
        
        fileprivate let titleLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = MessageAlert.titleConfig.alignment
            label.setContentHuggingPriority(.required, for: .vertical)
            return label
        }()
        
        
        fileprivate let messageLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = MessageAlert.messageConfig.alignment
            return label
        }()
    }
    
    private let contentView: ContentView
    
    @available(*, unavailable)
    public required init(title: Title?, customView: ActionAlert.CustomizedView) {
        fatalError()
    }
    
    public required init(title: Title?, message: Message?) {
        contentView = ContentView()
        contentView.titleLabel.attributedText = title?.title
        contentView.messageLabel.attributedText = message?.message
        super.init(customView: contentView)
        layout?.width = .fixed(270)
    }
    
    public override func willLayoutContainer() {
        super.willLayoutContainer()
        
        if title == nil {
            contentView.titleLabel.removeFromSuperview()
        } else {
            contentView.addSubview(contentView.titleLabel)
            contentView.titleLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(20)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.bottom.lessThanOrEqualToSuperview().offset(-20)
            }
        }
        if message == nil {
            contentView.messageLabel.removeFromSuperview()
        } else {
            contentView.addSubview(contentView.messageLabel)
            contentView.messageLabel.snp.remakeConstraints { make in
                make.top.greaterThanOrEqualToSuperview().offset(20)
                if title != nil {
                    make.top.equalTo(contentView.titleLabel.snp.bottom).offset(4)
                }
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.bottom.equalToSuperview().offset(-20)
            }
        }
    }
}
