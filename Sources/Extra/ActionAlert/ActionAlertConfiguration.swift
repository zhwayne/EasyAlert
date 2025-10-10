//
//  ActionAlertConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/5/26.
//

import UIKit

/// An extension that provides configuration support for action alerts.
///
/// This extension defines the configuration structure for action alerts, including
/// layout, styling, and behavior options that can be customized for different
/// alert presentations.
extension ActionAlert {

    /// A configuration structure that defines the appearance and behavior of action alerts.
    ///
    /// `Configuration` provides comprehensive control over the visual presentation
    /// and behavior of action alerts, including layout, styling, and action management.
    @MainActor public struct Configuration: ActionAlertableConfigurable {

        /// The layout guide that defines the positioning and sizing constraints for the alert.
        ///
        /// This property determines how the alert is positioned and sized within its container,
        /// with flexible width and height by default to accommodate different content sizes.
        public var layoutGuide: LayoutGuide = .init(width: .intrinsic, height: .intrinsic)

        /// The corner radius to apply to the alert's visual elements.
        ///
        /// This value determines the roundness of the alert's corners, affecting
        /// both the background and action button styling. The default value of 13
        /// provides a modern, rounded appearance.
        public var cornerRadius: CGFloat = 13

        /// A factory method that creates action views for the specified style.
        ///
        /// This method is responsible for creating the appropriate view representation
        /// for each action style, ensuring consistent appearance and behavior across
        /// different action types.
        ///
        /// - Parameter style: The action style for which to create a view.
        /// - Returns: A view that conforms to `ActionContent` and represents the action.
        public var makeActionView: (Action.Style) -> (UIView & ActionContent) = { style in
            ActionView(style: style)
        }

        /// A factory method that creates the layout manager for the alert's actions.
        ///
        /// This method returns a layout manager that will be responsible for positioning
        /// and arranging the action buttons within the alert.
        ///
        /// - Returns: A layout manager that conforms to `ActionLayout`.
        public var makeActionLayout: () -> any ActionLayout = {
            AlertActionLayout()
        }

        /// Creates a new action alert configuration with default values.
        ///
        /// This initializer sets up the configuration with standard values that
        /// provide a good default appearance and behavior for action alerts.
        init() { }

        /// The global configuration instance used as the default for action alerts.
        ///
        /// This static property provides a shared configuration instance that can be
        /// used as a default for action alerts, ensuring consistent behavior across
        /// the application.
        public static var global = Configuration()
    }
}
