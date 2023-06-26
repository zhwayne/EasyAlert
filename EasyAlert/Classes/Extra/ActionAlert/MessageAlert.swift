//
//  MessageAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/8/2.
//

import UIKit

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

    let titleConfiguration: TitleConfiguration
    let messageConfiguration: MessageConfiguration

    public required init(
        title: Title?,
        message: Message?,
        configuration: ActionAlertbleConfigurable? = nil
    ) {
        if let configuration = configuration as? MessageAlert.Configuration {
            self.titleConfiguration =  configuration.titleConfiguration
            self.messageConfiguration = configuration.messageConfiguration
        } else {
            self.titleConfiguration =  MessageAlert.Configuration.global.titleConfiguration
            self.messageConfiguration =  MessageAlert.Configuration.global.messageConfiguration
        }
        
        contentView = ContentView()
        super.init(customizable: contentView, configuration: configuration)
        configAttributes()
        contentView.titleLabel.attributedText = text(for: title)
        contentView.messageLabel.attributedText = text(for: message)
    }

    @available(*, unavailable)
    public required init(customizable: AlertCustomizable, configuration: ActionAlertbleConfigurable? = nil) {
        fatalError("init(customizable:configuration:) has not been implemented")
    }
    
    private func configAttributes() {
        contentView.titleLabel.textAlignment = titleConfiguration.alignment
        contentView.titleLabel.textColor = titleConfiguration.color
        contentView.titleLabel.font = titleConfiguration.font

        contentView.messageLabel.textAlignment = messageConfiguration.alignment
        contentView.messageLabel.textColor = messageConfiguration.color
        contentView.messageLabel.font = messageConfiguration.font
    }

    public override func willLayoutContainer() {
        super.willLayoutContainer()

        if title == nil {
            contentView.titleLabel.removeFromSuperview()
        } else {
            if contentView != contentView.titleLabel {
                contentView.addSubview(contentView.titleLabel)
                contentView.titleLabel.translatesAutoresizingMaskIntoConstraints = false
                contentView.titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17).isActive = true
                contentView.titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
                contentView.titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
                contentView.titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -17).isActive = true
            }
        }
        if message == nil {
            contentView.messageLabel.removeFromSuperview()
        } else {
            if contentView != contentView.messageLabel {
                contentView.addSubview(contentView.messageLabel)
                contentView.messageLabel.translatesAutoresizingMaskIntoConstraints = false
                contentView.messageLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 17).isActive = true
                if title != nil {
                    contentView.messageLabel.topAnchor.constraint(equalTo: contentView.titleLabel.bottomAnchor, constant: 3).isActive = true
                }
                contentView.messageLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
                contentView.messageLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
                contentView.messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
            }
        }
    }
}
