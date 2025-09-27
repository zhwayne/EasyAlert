//
//  MessageAlertConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import UIKit

/// An extension that provides configuration support for message alerts.
///
/// This extension defines the configuration structure for message alerts, including
/// title and message styling options along with the standard action alert configuration.
extension MessageAlert {

    /// A configuration structure that defines the appearance and behavior of message alerts.
    ///
    /// `Configuration` extends the action alert configuration to include specific
    /// settings for title and message text styling, providing comprehensive
    /// control over the visual presentation of message alerts.
    @MainActor public struct Configuration: ActionAlertableConfigurable {

        /// The layout guide that defines the positioning and sizing constraints for the alert.
        ///
        /// This property delegates to the underlying action alert configuration
        /// while providing the ability to customize the layout behavior.
        public var layoutGuide: LayoutGuide {
            get { actionAlertConfiguration.layoutGuide }
            set { actionAlertConfiguration.layoutGuide = newValue }
        }

        /// The corner radius to apply to the alert's visual elements.
        ///
        /// This property delegates to the underlying action alert configuration
        /// while providing the ability to customize the corner radius.
        public var cornerRadius: CGFloat {
            get { actionAlertConfiguration.cornerRadius }
            set { actionAlertConfiguration.cornerRadius = newValue }
        }

        /// A factory method that creates action views for the specified style.
        ///
        /// This property delegates to the underlying action alert configuration
        /// while providing the ability to customize action view creation.
        public var makeActionView: (Action.Style) -> (UIView & ActionContent) {
            get { actionAlertConfiguration.makeActionView }
            set { actionAlertConfiguration.makeActionView = newValue }
        }

        /// A factory method that creates the layout manager for the alert's actions.
        ///
        /// This property delegates to the underlying action alert configuration
        /// while providing the ability to customize the layout manager.
        public var makeActionLayout: () -> any ActionLayout {
            get { actionAlertConfiguration.makeActionLayout }
            set { actionAlertConfiguration.makeActionLayout = newValue }
        }

        /// The underlying action alert configuration that provides base functionality.
        private var actionAlertConfiguration: ActionAlert.Configuration

        /// The configuration for the title label's appearance and behavior.
        public var titleConfiguration = TitleConfiguration()

        /// The configuration for the message label's appearance and behavior.
        public var messageConfiguration = MessageConfiguration()

        /// Creates a new message alert configuration with the specified action alert configuration.
        ///
        /// This initializer sets up the configuration with the provided action alert
        /// configuration or uses the global configuration if none is provided.
        /// The layout guide width is automatically set to 270 points for message alerts.
        ///
        /// - Parameter actionAlertConfiguration: An optional action alert configuration to use as a base.
        init(_ actionAlertConfiguration: ActionAlert.Configuration? = nil) {
            self.actionAlertConfiguration = actionAlertConfiguration ?? ActionAlert.Configuration.global
            self.actionAlertConfiguration.layoutGuide.width = .fixed(270)
        }

        /// The global configuration instance used as the default for message alerts.
        public static var global = Configuration()
    }
}

/// A private computed property that returns the default text color for labels.
///
/// This property provides a consistent default color that adapts to the current
/// appearance (light/dark mode) using the system label color.
private var defaultTextColor: UIColor {
    return UIColor.label
}

/// An extension that provides title configuration for message alerts.
///
/// This extension defines the configuration structure for title text styling,
/// including alignment, font, and color options.
extension MessageAlert {

    /// A configuration structure that defines the appearance of the title label.
    ///
    /// `TitleConfiguration` provides comprehensive control over the visual
    /// presentation of the alert's title text, including typography and alignment.
    public struct TitleConfiguration {

        /// The text alignment for the title label.
        ///
        /// This property determines how the title text is aligned within its label.
        public var alignment: NSTextAlignment = .center

        /// The font used for the title text.
        ///
        /// This property defines the typography for the title, including size and weight.
        public var font: UIFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        /// The text color for the title label.
        ///
        /// This property determines the color of the title text.
        public var color: UIColor = defaultTextColor

        /// Creates a new title configuration with default values.
        public init() {}
    }
}

/// An extension that provides message configuration for message alerts.
///
/// This extension defines the configuration structure for message text styling,
/// including alignment, font, and color options.
extension MessageAlert {

    /// A configuration structure that defines the appearance of the message label.
    ///
    /// `MessageConfiguration` provides comprehensive control over the visual
    /// presentation of the alert's message text, including typography and alignment.
    public struct MessageConfiguration {

        /// The text alignment for the message label.
        ///
        /// This property determines how the message text is aligned within its label.
        public var alignment: NSTextAlignment = .center

        /// The font used for the message text.
        ///
        /// This property defines the typography for the message, including size and weight.
        public var font: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)

        /// The text color for the message label.
        ///
        /// This property determines the color of the message text.
        public var color: UIColor = defaultTextColor

        /// Creates a new message configuration with default values.
        public init() {}
    }
}

