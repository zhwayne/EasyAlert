//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/28.
//

import UIKit

open class ActionAlert: Alert {
    
    private let actionGroupView: ActionGroupView
    
    private let configuration: ActionAlertbleConfigurable
    
    public required init(
        customView: CustomizedView,
        configuration: ActionAlertbleConfigurable = ActionAlert.Configuration.globalConfiguration
    ) {
        self.configuration = configuration
        actionGroupView = ActionGroupView(customView: customView,
                                           actionLayout: self.configuration.actionLayout)
        super.init(customView: actionGroupView)
        let transitionCoordinator = ActionAlertTransitionCoordinator()
        transitionCoordinator.alertCustomView = actionGroupView
        self.transitionCoordinator = transitionCoordinator
    }
    
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        actionGroupView.setCornerRadius(configuration.cornerRadius)
        
        if actionGroupView.customView is TitleMessageContentView {
            _messageAlert_willLayoutContainer()
        }
    }
    
    // MARK: - Message and Title
    
    var titleConfiguration: TitleConfiguration?
    var messageConfiguration: MessageConfiguration?
}

extension ActionAlert: ActionAlertble {
    
    public func addAction(_ action: Action) {
        assert(isShowing == false)
        actionGroupView.actions.append(action)
        setViewForAction(action)
    }
    
    private func setViewForAction(_ action: Action) {
        if action.view == nil {
            action.view = configuration.actionViewType.init(style: action.style)
            action.view?.title = action.title
        }
    }
}

// MARK: - Message and Title

extension ActionAlert {
    
    public var title: String? {
        titleMessageContentView.titleLabel.attributedText?.string
    }
    
    public var message: String? {
        titleMessageContentView.messageLabel.attributedText?.string
    }
    
    private var titleMessageContentView: TitleMessageContentView {
        actionGroupView.customView as! TitleMessageContentView
    }
    
    private final class TitleMessageContentView: UIView, AlertCustomizable {
        
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
    
    public convenience init(
        title: Title?,
        message: Message?,
        configuration: Configuration = .globalConfiguration
    ) {
        self.init(customView: TitleMessageContentView(), configuration: configuration)
        self.titleConfiguration = configuration.titleConfiguration
        self.messageConfiguration = configuration.messageConfiguration
        configAttributes()
        titleMessageContentView.titleLabel.attributedText = text(for: title)
        titleMessageContentView.messageLabel.attributedText = text(for: message)
        transitionCoordinator.size.width = .fixed(270)
    }
    
    private func configAttributes() {
        // Config title attributes.
        guard let titleConfiguration, let messageConfiguration else { return }
        titleMessageContentView.titleLabel.textAlignment = titleConfiguration.alignment
        titleMessageContentView.titleLabel.textColor = titleConfiguration.color
        titleMessageContentView.titleLabel.font = titleConfiguration.font
        // Config message attributes.
        titleMessageContentView.messageLabel.textAlignment = messageConfiguration.alignment
        titleMessageContentView.messageLabel.textColor = messageConfiguration.color
        titleMessageContentView.messageLabel.font = messageConfiguration.font
    }
    
    private func _messageAlert_willLayoutContainer() {
        
        if title == nil {
            titleMessageContentView.titleLabel.removeFromSuperview()
        } else {
            if titleMessageContentView != titleMessageContentView.titleLabel {
                titleMessageContentView.addSubview(titleMessageContentView.titleLabel)
                titleMessageContentView.titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleMessageContentView.titleLabel.topAnchor.constraint(equalTo: titleMessageContentView.topAnchor, constant: 17).isActive = true
                titleMessageContentView.titleLabel.leftAnchor.constraint(equalTo: titleMessageContentView.leftAnchor, constant: 16).isActive = true
                titleMessageContentView.titleLabel.rightAnchor.constraint(equalTo: titleMessageContentView.rightAnchor, constant: -16).isActive = true
                titleMessageContentView.titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: titleMessageContentView.bottomAnchor, constant: -17).isActive = true
            }
        }
        if message == nil {
            titleMessageContentView.messageLabel.removeFromSuperview()
        } else {
            if titleMessageContentView != titleMessageContentView.messageLabel {
                titleMessageContentView.addSubview(titleMessageContentView.messageLabel)
                titleMessageContentView.messageLabel.translatesAutoresizingMaskIntoConstraints = false
                titleMessageContentView.messageLabel.topAnchor.constraint(greaterThanOrEqualTo: titleMessageContentView.topAnchor, constant: 17).isActive = true
                if title != nil {
                    titleMessageContentView.messageLabel.topAnchor.constraint(equalTo: titleMessageContentView.titleLabel.bottomAnchor, constant: 3).isActive = true
                }
                titleMessageContentView.messageLabel.leftAnchor.constraint(equalTo: titleMessageContentView.leftAnchor, constant: 16).isActive = true
                titleMessageContentView.messageLabel.rightAnchor.constraint(equalTo: titleMessageContentView.rightAnchor, constant: -16).isActive = true
                titleMessageContentView.messageLabel.bottomAnchor.constraint(equalTo: titleMessageContentView.bottomAnchor, constant: -20).isActive = true
            }
        }
    }
}
