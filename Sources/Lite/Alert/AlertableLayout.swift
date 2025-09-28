//
//  AlertableLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

/// An enum that defines different width sizing options for alerts.
@MainActor public enum Width {

    /// Fixed width: the alert has a specific width regardless of container size.
    case fixed(CGFloat)

    /// Flexible width: the alert adapts to the container width with insets.
    case flexible

    /// Fractional width: the alert width is a fraction of the container width.
    ///
    /// For example, `.fractional(0.8)` sets the width to 80% of the container's width
    /// adjusted by content insets.
    case fractional(CGFloat)
}

/// An enum that defines different height sizing options for alerts.
@MainActor public enum Height {

    /// Fixed height: the alert has a specific height regardless of content.
    case fixed(CGFloat)

    /// Flexible height: the alert adapts to the container height with insets.
    case flexible

    /// Fractional height: the alert height is a fraction of the container height.
    ///
    /// For example, `.fractional(0.5)` sets the height to 50% of the container's height
    /// adjusted by content insets.
    case fractional(CGFloat)
}

/// A guide that defines the layout constraints and insets for an alert.
///
/// `LayoutGuide` provides a comprehensive way to specify how an alert should be
/// sized and positioned within its container. It supports different sizing modes
/// for both width and height, along with content insets and safe area handling.
@MainActor public struct LayoutGuide {

    /// The width sizing mode for the alert.
    public var width: Width

    /// The height sizing mode for the alert.
    public var height: Height

    /// The insets to apply around the alert content.
    public var contentInsets: UIEdgeInsets

    /// The safe-area edges to ignore when positioning.
    ///
    /// Use this to specify which edges should use the container's bounds instead of
    /// the safe area as the reference for layout. For example, include `.bottom`
    /// to anchor to the container's bottom edge. Defaults to none.
    public var ignoredSafeAreaEdges: UIRectEdge = []

    /// Creates a new layout guide with the specified parameters.
    ///
    /// - Parameters:
    ///   - width: The width sizing mode for the alert.
    ///   - height: The height sizing mode for the alert.
    ///   - contentInsets: The insets to apply around the alert content. Defaults to `.zero`.
    ///   - ignoredSafeAreaEdges: Safe-area edges to ignore (defaults to `[]`).
    public init(
        width: Width,
        height: Height,
        contentInsets: UIEdgeInsets = .zero,
        ignoredSafeAreaEdges: UIRectEdge = []
    ) {
        self.width = width
        self.height = height
        self.contentInsets = contentInsets
        self.ignoredSafeAreaEdges = ignoredSafeAreaEdges
    }
}

/// A protocol that defines objects capable of managing alert layout.
///
/// `AlertableLayout` provides the interface for customizing how alerts are positioned
/// and sized within their containers. Implementations can provide different layout
/// behaviors, such as centering, edge alignment, or custom positioning logic.
@MainActor public protocol AlertableLayout {

    /// Updates the layout of the alert during the transition.
    ///
    /// This method is called whenever the alert's layout needs to be updated,
    /// such as during presentation, dismissal, or orientation changes.
    ///
    /// - Parameters:
    ///   - context: The layout context containing views and layout information.
    ///   - layoutGuide: The layout guide that defines size and positioning constraints.
    func updateLayout(context: LayoutContext, layoutGuide: LayoutGuide)
}

/// A context object for use during the transition animation of an alert.
///
/// `LayoutContext` provides all the necessary information for layout calculations,
/// including the container view, dimming view, presented view, and interface orientation.
@MainActor public struct LayoutContext {
    
    /// The backdrop view that contains the alert.
    public let containerView: UIView

    /// The dimming view that provides the background effect.
    public let dimmingView: UIView

    /// The view that contains the custom alert content.
    public let presentedView: UIView

    /// The current interface orientation of the device.
    public let interfaceOrientation: UIInterfaceOrientation
}
