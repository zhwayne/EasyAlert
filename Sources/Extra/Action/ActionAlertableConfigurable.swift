//
//  ActionAlertableConfigurable.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import UIKit

/// A protocol that defines the configuration requirements for action-based alerts.
///
/// `ActionAlertableConfigurable` provides a standardized interface for configuring
/// action alerts with specific styling, layout, and behavior options. This protocol
/// enables consistent configuration across different alert implementations.
@MainActor public protocol ActionAlertableConfigurable {

    /// The corner radius to apply to the alert's visual elements.
    ///
    /// This value determines the roundness of the alert's corners, affecting
    /// both the background and action button styling.
    var cornerRadius: CGFloat { get }

    /// The layout guide that defines the positioning and sizing constraints for the alert.
    ///
    /// This guide determines how the alert is positioned and sized within its container.
    var layoutGuide: LayoutGuide { get }

    /// A factory method that creates action views for the specified style.
    ///
    /// This method is responsible for creating the appropriate view representation
    /// for each action style, ensuring consistent appearance and behavior.
    ///
    /// - Parameter style: The action style for which to create a view.
    /// - Returns: A view that conforms to `ActionContent` and represents the action.
    var makeActionView: (Action.Style) -> (UIView & ActionContent) { get }

    /// A factory method that creates the layout manager for the alert's actions.
    ///
    /// This method returns a layout manager that will be responsible for positioning
    /// and arranging the action buttons within the alert.
    ///
    /// - Returns: A layout manager that conforms to `ActionLayout`.
    var makeActionLayout: () -> ActionLayout { get }
}

/// An extension that provides utility methods for configuration objects.
///
/// This extension provides helper methods that can be used by configuration
/// implementations to access their properties dynamically.
extension ActionAlertableConfigurable {

    /// Retrieves the value of a property by its label name using reflection.
    ///
    /// This method uses Swift's reflection capabilities to access properties
    /// of the configuration object by their label names, enabling dynamic
    /// property access and introspection.
    ///
    /// - Parameter label: The label name of the property to retrieve.
    /// - Returns: The value of the property if found, otherwise `nil`.
    func value(for label: String) -> Any? {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if child.label == label {
                return child.value
            }
        }
        return nil
    }
}
