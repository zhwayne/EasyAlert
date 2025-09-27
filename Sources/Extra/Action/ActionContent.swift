//
//  ActionContent.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

/// A protocol that defines the interface for custom action views.
///
/// `ActionContent` provides the basic interface that custom action views must implement
/// to work with the EasyAlert framework. It defines properties for title, highlighting,
/// enabling, and styling of action buttons.
@MainActor public protocol ActionContent: Dismissible {

    /// The title text displayed on the action button.
    var title: String? { get set }

    /// A Boolean value indicating whether the action is currently highlighted.
    ///
    /// This property is typically set to `true` when the user is pressing the action button.
    /// Developers can use this state to update the UI appearance accordingly.
    var isHighlighted: Bool { get set }

    /// A Boolean value indicating whether the action is enabled.
    ///
    /// When `false`, the action button should appear disabled and not respond to user interaction.
    /// Developers can use this state to update the UI appearance accordingly.
    var isEnabled: Bool { get set }

    /// The visual style of the action.
    var style: Action.Style { get }

    /// The view that represents this action in the user interface.
    var view: UIView { get }
}

/// A default implementation of the `view` property for `UIView` conforming types.
///
/// This extension provides a default implementation that returns the view itself
/// when the conforming type is a `UIView`. This eliminates the need for custom
/// implementations in most cases.
extension ActionContent where Self: UIView {

    /// Returns the view itself when the conforming type is a `UIView`.
    ///
    /// This default implementation allows any `UIView` that conforms to `ActionContent`
    /// to automatically satisfy the `view` property requirement.
    public var view: UIView { self }
}
