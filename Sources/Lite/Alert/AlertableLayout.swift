//
//  AlertableLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

/// An enum that defines different width sizing options for alerts and sheets.
@MainActor public enum Width {

    /// Fixed width: the alert/sheet has a specific width regardless of container size.
    case fixed(CGFloat)

    /// Fractional width: the alert/sheet width is a fraction of the container width.
    ///
    /// For example, `.fractional(0.8)` sets the width to 80% of the container's width
    /// adjusted by content insets.
    case fractional(CGFloat)

    /// Intrinsic width: the alert/sheet width is determined by its intrinsic content size.
    ///
    /// This mode allows the alert/sheet to size itself based on its intrinsic content size,
    /// similar to how UIStackView sizes itself based on its arranged subviews.
    case intrinsic
}

/// An enum that defines different height sizing options for alerts and sheets.
@MainActor public enum Height {

    /// Fixed height: the alert/sheet has a specific height regardless of content.
    case fixed(CGFloat)

    /// Fractional height: the alert/sheet height is a fraction of the container height.
    ///
    /// For example, `.fractional(0.5)` sets the height to 50% of the container's height
    /// adjusted by content insets.
    case fractional(CGFloat)

    /// Intrinsic height: the sheet height is determined by its intrinsic content size.
    ///
    /// This mode allows the sheet to size itself based on its intrinsic content size,
    /// similar to how UIStackView sizes itself based on its arranged subviews.
    case intrinsic
}

/// A guide that defines the layout constraints and insets for alerts and sheets.
///
/// `LayoutGuide` provides a comprehensive way to specify how an alert or sheet should be
/// sized and positioned within its container. It supports different sizing modes
/// for both width and height, along with content insets and safe area handling.
/// The height options include specialized modes for sheets such as intrinsic sizing.
@MainActor public struct LayoutGuide {

    /// The width sizing mode for the alert/sheet.
    public var width: Width

    /// The height sizing mode for the alert/sheet.
    public var height: Height

    /// The insets to apply around the alert content.
    public var contentInsets: UIEdgeInsets

    /// Describes which edges may extend into the safe area. Empty set preserves all.
    ///
    /// By default, `.all` are enabled.
    public var edgesForExtendedSafeArea: ExtendedSafeAreaEdges = .all

    /// An option set of safe-area edges that are allowed to extend.
    @MainActor public struct ExtendedSafeAreaEdges: @MainActor OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        public static let top    = ExtendedSafeAreaEdges(rawValue: 1 << 0)
        public static let left   = ExtendedSafeAreaEdges(rawValue: 1 << 1)
        public static let bottom = ExtendedSafeAreaEdges(rawValue: 1 << 2)
        public static let right  = ExtendedSafeAreaEdges(rawValue: 1 << 3)

        public static let all: ExtendedSafeAreaEdges = [.top, .left, .bottom, .right]
    }

    /// Creates a new layout guide with the specified parameters.
    ///
    /// - Parameters:
    ///   - width: The width sizing mode for the alert/sheet.
    ///   - height: The height sizing mode for the alert/sheet.
    ///   - contentInsets: The insets to apply around the alert/sheet content. Defaults to `.zero`.
    ///   - edgesForExtendedSafeArea: The edges that may extend into the safe area. Defaults to `.all`.
    public init(
        width: Width,
        height: Height,
        contentInsets: UIEdgeInsets = .zero,
        edgesForExtendedSafeArea: ExtendedSafeAreaEdges = .all
    ) {
        self.width = width
        self.height = height
        self.contentInsets = contentInsets
        self.edgesForExtendedSafeArea = edgesForExtendedSafeArea
    }
}

/// A protocol that defines objects capable of managing alert and sheet layout.
///
/// `AlertableLayout` provides the interface for customizing how alerts and sheets are positioned
/// and sized within their containers. Implementations install and update Auto Layout
/// constraints rather than returning frames.
@MainActor public protocol AlertableLayout {

    /// Installs or updates Auto Layout constraints for the presented view.
    ///
    /// This method is called whenever the alert's or sheet's layout needs to be updated,
    /// such as during presentation, dismissal, trait or orientation changes.
    /// Implementations should deactivate any previously installed constraints
    /// they own and then activate the new set that matches the current context
    /// and `layoutGuide`.
    ///
    /// - Parameters:
    ///   - context: The layout context containing views and layout information.
    ///   - layoutGuide: The layout guide that defines size and positioning constraints.
    func updateLayoutConstraints(context: LayoutContext, layoutGuide: LayoutGuide)
}

/// A context object for use during the transition animation of an alert or sheet.
///
/// `LayoutContext` provides all the necessary information for layout calculations,
/// including the container view, dimming view, presented view, and interface orientation.
@MainActor public struct LayoutContext {
    
    /// The backdrop view that contains the alert/sheet.
    public let containerView: UIView

    /// The dimming view that provides the background effect.
    public let dimmingView: UIView

    /// The view that contains the custom alert/sheet content.
    public let presentedView: UIView

    /// The current interface orientation of the device.
    public let interfaceOrientation: UIInterfaceOrientation
}

// (Frame-based helper methods removed in favor of direct Auto Layout constraints.)
