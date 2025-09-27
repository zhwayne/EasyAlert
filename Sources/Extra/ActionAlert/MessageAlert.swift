//
//  MessageAlert.swift
//  EasyAlert
//
//  Created by iya on 2021/8/2.
//

import UIKit

/// An alert that displays a title and message with action buttons.
///
/// `MessageAlert` extends `ActionAlert` to provide a specialized alert for displaying
/// text content with title and message labels. It supports both plain text and
/// attributed text for rich formatting.
public final class MessageAlert: ActionAlert {

    /// The title text displayed in the alert.
    ///
    /// This property provides access to the plain text content of the title label.
    public var title: String? {
        contentView.titleLabel.attributedText?.string
    }

    /// The message text displayed in the alert.
    ///
    /// This property provides access to the plain text content of the message label.
    public var message: String? {
        contentView.messageLabel.attributedText?.string
    }

    /// A private content view that manages the title and message labels.
    ///
    /// This view handles the layout and display of the alert's text content,
    /// including proper spacing and alignment between title and message.
    private final class ContentView: UIView, AlertContent {

        /// The label that displays the alert's title text.
        ///
        /// This label is configured for multi-line text with high content hugging priority
        /// to ensure proper layout behavior.
        fileprivate let titleLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.setContentHuggingPriority(.required, for: .vertical)
            return label
        }()

        /// The label that displays the alert's message text.
        ///
        /// This label is configured for multi-line text to accommodate longer messages.
        fileprivate let messageLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            return label
        }()
    }

    /// The content view that contains the title and message labels.
    private let contentView: ContentView

    /// The configuration for the title label's appearance and behavior.
    let titleConfiguration: TitleConfiguration
    
    /// The configuration for the message label's appearance and behavior.
    let messageConfiguration: MessageConfiguration

    /// Creates a new message alert with the specified title, message, and configuration.
    ///
    /// This initializer sets up the alert with the provided text content and applies
    /// the specified configuration for styling and behavior. The title and message
    /// can be plain text, attributed text, or other supported text types.
    ///
    /// - Parameters:
    ///   - title: The title text to display in the alert.
    ///   - message: The message text to display in the alert.
    ///   - configuration: An optional configuration object. If `nil`, the global configuration is used.
    public required init(
        title: Title?,
        message: Message?,
        configuration: ActionAlertableConfigurable? = nil
    ) {
        let configuration = (configuration as? MessageAlert.Configuration) ?? MessageAlert.Configuration.global
        self.titleConfiguration =  configuration.titleConfiguration
        self.messageConfiguration = configuration.messageConfiguration

        contentView = ContentView()
        super.init(content: contentView, configuration: configuration)
        layoutGuide = configuration.layoutGuide

        configureAttributes()
        contentView.titleLabel.attributedText = text(for: title)
        contentView.messageLabel.attributedText = text(for: message)
    }

    /// This initializer is not supported and will cause a fatal error.
    ///
    /// - Parameters:
    ///   - content: The alert content (unused).
    ///   - configuration: The configuration (unused).
    /// - Returns: This method always calls `fatalError`.
    @available(*, unavailable)
    public required init(content: AlertContent, configuration: ActionAlertableConfigurable? = nil) {
        fatalError("init(customizable:configuration:) has not been implemented")
    }

    /// Configures the visual attributes of the title and message labels.
    ///
    /// This method applies the configuration settings to the labels, including
    /// alignment, color, and font properties.
    private func configureAttributes() {
        contentView.titleLabel.textAlignment = titleConfiguration.alignment
        contentView.titleLabel.textColor = titleConfiguration.color
        contentView.titleLabel.font = titleConfiguration.font

        contentView.messageLabel.textAlignment = messageConfiguration.alignment
        contentView.messageLabel.textColor = messageConfiguration.color
        contentView.messageLabel.font = messageConfiguration.font
    }

    /// Called before the alert container is laid out to configure the label layout.
    ///
    /// This method sets up the constraints for the title and message labels based on
    /// their presence. It handles the proper spacing and positioning of labels
    /// with appropriate margins and alignment.
    public override func willLayoutContainer() {
        super.willLayoutContainer()

        if title == nil {
            contentView.titleLabel.removeFromSuperview()
        } else {
            contentView.addSubview(contentView.titleLabel)
            contentView.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17).isActive = true
            contentView.titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
            contentView.titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
            contentView.titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -17).isActive = true
        }
        if message == nil {
            contentView.messageLabel.removeFromSuperview()
            contentView.titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17).isActive = true
        } else {
            contentView.addSubview(contentView.messageLabel)
            contentView.messageLabel.translatesAutoresizingMaskIntoConstraints = false
            if title != nil {
                contentView.messageLabel.topAnchor.constraint(equalTo: contentView.titleLabel.bottomAnchor, constant: 3).isActive = true
            } else {
                contentView.messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17).isActive = true
            }
            contentView.messageLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
            contentView.messageLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
            contentView.messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
    }
}
