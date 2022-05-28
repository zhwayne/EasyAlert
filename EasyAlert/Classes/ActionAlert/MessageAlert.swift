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
            label.setContentHuggingPriority(.required, for: .vertical)
            return label
        }()
        
        
        fileprivate let messageLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            return label
        }()
    }
    
    private let contentView: ContentView
    
    let titleConfig: TitleConfiguration
    let messageConfig: MessageConfiguration
    
    @available(*, unavailable)
    public required init(title: Title?, customView: ActionAlert.CustomizedView) {
        fatalError()
    }
    
    public required init(
        title: Title?,
        message: Message?,
        titleConfig: TitleConfiguration? = nil,
        messageConfig: MessageConfiguration? = nil
    ) {
        self.titleConfig = titleConfig ?? MessageAlert.titleConfig
        self.messageConfig = messageConfig ?? MessageAlert.messageConfig
        contentView = ContentView()
        super.init(customView: contentView)
        contentView.titleLabel.attributedText = text(for: title)
        contentView.messageLabel.attributedText = text(for: message)
        layout?.width = .fixed(270)
    }
    
    public override func willLayoutContainer() {
        super.willLayoutContainer()
        
        if title == nil {
            contentView.titleLabel.removeFromSuperview()
        } else {
            contentView.titleLabel.textAlignment = titleConfig.alignment
            contentView.titleLabel.textColor = titleConfig.color
            contentView.titleLabel.font = titleConfig.font
            contentView.addSubview(contentView.titleLabel)
            contentView.titleLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(17)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.bottom.lessThanOrEqualToSuperview().offset(-17)
            }
        }
        if message == nil {
            contentView.messageLabel.removeFromSuperview()
        } else {
            contentView.messageLabel.textAlignment = messageConfig.alignment
            contentView.messageLabel.textColor = messageConfig.color
            contentView.messageLabel.font = messageConfig.font
            contentView.addSubview(contentView.messageLabel)
            contentView.messageLabel.snp.remakeConstraints { make in
                make.top.greaterThanOrEqualToSuperview().offset(17)
                if title != nil {
                    make.top.equalTo(contentView.titleLabel.snp.bottom).offset(3)
                }
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-20)
            }
        }
    }
}
