//
//  ActionSheetConfiguration.swift
//  EasyAlert
//
//  Created by iya on 2022/12/6.
//

import UIKit

/// An extension that provides configuration support for action sheets.
///
/// This extension defines the configuration structure for action sheets, including
/// layout, styling, and behavior options that can be customized for different
/// action sheet presentations.
extension ActionSheet {

    /// A configuration structure that defines the appearance and behavior of action sheets.
    ///
    /// `Configuration` provides comprehensive control over the visual presentation
    /// and behavior of action sheets, including layout, styling, and action management.
    @MainActor public struct Configuration: ActionAlertableConfigurable {

        /// The layout guide that defines the positioning and sizing constraints for the action sheet.
        ///
        /// This property determines how the action sheet is positioned and sized within its container,
        /// with fractional width and flexible height by default.
        public var layoutGuide: LayoutGuide = .init(
            width: .fractional(1),
            height: .flexible,
            contentInsets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
            edgesForExtendedSafeArea: []
        )

        /// The corner radius to apply to the action sheet's visual elem	ents.
        ///
        /// This value determines the roundness of the action sheet's corners, affecting
        /// both the background and action button styling. The default value of 13
        /// provides a modern, rounded appearance.
        public var cornerRadius: CGFloat = 13

        /// The spacing between regular actions and cancel actions.
        ///
        /// This value determines the visual separation between regular action buttons
        /// and cancel action buttons, providing clear visual distinction between
        /// different action types.
        public var cancelSpacing: CGFloat = 8

        /// A factory method that creates action views for the specified style.
        ///
        /// This method is responsible for creating the appropriate view representation
        /// for each action style, ensuring consistent appearance and behavior across
        /// different action types in action sheets.
        ///
        /// - Parameter style: The action style for which to create a view.
        /// - Returns: A view that conforms to `ActionContent` and represents the action.
        public var makeActionView: (Action.Style) -> (UIView & ActionContent) = { style in
            ActionView(style: style)
        }

        /// A factory method that creates the layout manager for the action sheet's actions.
        ///
        /// This method returns a layout manager that will be responsible for positioning
        /// and arranging the action buttons within the action sheet.
        ///
        /// - Returns: A layout manager that conforms to `ActionLayout`.
        public var makeActionLayout: () -> any ActionLayout = {
            SheetActionLayout()
        }

        /// Creates a new action sheet configuration with default values.
        ///
        /// This initializer sets up the configuration with standard values that
        /// provide a good default appearance and behavior for action sheets.
        init() { }

        /// The global configuration instance used as the default for action sheets.
        ///
        /// This static property provides a shared configuration instance that can be
        /// used as a default for action sheets, ensuring consistent behavior across
        /// the application.
        public static var global = Configuration()
    }
}
