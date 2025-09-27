//
//  ActionLayout.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

/// A protocol that defines the layout behavior for action buttons within an alert.
///
/// `ActionLayout` provides a flexible system for positioning and arranging action buttons
/// in various configurations. Implementations can define custom layouts for different
/// alert styles and orientations.
@MainActor public protocol ActionLayout {

    /// A Boolean value that determines whether separators between actions should be hidden.
    ///
    /// When `true`, separators between action buttons are not displayed.
    /// When `false`, separators are shown to provide visual separation between actions.
    var prefersSeparatorHidden: Bool { get }

    /// Lays out the specified views within the given container.
    ///
    /// This method is responsible for positioning and sizing the action button views
    /// within the container view according to the layout strategy.
    ///
    /// - Parameters:
    ///   - views: An array of views representing the action buttons to be laid out.
    ///   - container: The container view that will hold the action button views.
    mutating func layout(views: [UIView], container: UIView)

    /// Creates a new instance of the action layout.
    init()
}

/// A default implementation that provides common behavior for action layouts.
///
/// This extension provides default implementations for common layout properties
/// and methods, reducing the implementation burden for custom layouts.
public extension ActionLayout {

    /// The default value for separator visibility.
    ///
    /// By default, separators are shown between action buttons.
    var prefersSeparatorHidden: Bool { false }
}

/// An extension that provides utility methods for action layouts.
///
/// This extension provides helper methods that can be used by action layout
/// implementations to create common UI elements.
public extension ActionLayout {

    /// Creates a new separator view for use between action buttons.
    ///
    /// This method returns a vibrant separator view that provides visual
    /// separation between action buttons with proper styling.
    ///
    /// - Returns: A new separator view configured for use between actions.
    func generateSeparatorView() -> UIView {
        ActionVibrantSeparatorView()
    }
}
