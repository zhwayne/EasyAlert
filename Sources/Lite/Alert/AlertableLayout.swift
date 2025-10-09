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
    ///   - width: The width sizing mode for the alert.
    ///   - height: The height sizing mode for the alert.
    ///   - contentInsets: The insets to apply around the alert content. Defaults to `.zero`.
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

/// A protocol that defines objects capable of managing alert layout.
///
/// `AlertableLayout` provides the interface for customizing how alerts are positioned
/// and sized within their containers. Implementations can provide different layout
/// behaviors, such as centering, edge alignment, or custom positioning logic.
@MainActor public protocol AlertableLayout {

    /// Calculates the frame that should be applied to the presented view.
    ///
    /// This method is called whenever the alert's layout needs to be updated,
    /// such as during presentation, dismissal, or orientation changes.
    ///
    /// - Parameters:
    ///   - context: The layout context containing views and layout information.
    ///   - layoutGuide: The layout guide that defines size and positioning constraints.
    /// - Returns: The frame that should be assigned to the presented view.
    func frameOfPresentedView(context: LayoutContext, layoutGuide: LayoutGuide) -> CGRect
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

// MARK: - Frame-based layout helpers

@MainActor
extension AlertableLayout {

    /// Calculates the effective bounds for layout by applying safe-area adjustments.
    ///
    /// - Parameters:
    ///   - context: The current layout context.
    ///   - layoutGuide: The layout guide that describes sizing behaviour.
    /// - Returns: A rectangle describing the usable layout region.
    func layoutBounds(for context: LayoutContext, layoutGuide: LayoutGuide) -> CGRect {
        let containerView = context.containerView
        var bounds = containerView.bounds
        guard bounds.width > 0 || bounds.height > 0 else { return .zero }

        let safeInsets = containerView.safeAreaInsets
        bounds.origin.x += safeInsets.left
        bounds.origin.y += safeInsets.top
        bounds.size.width -= (safeInsets.left + safeInsets.right)
        bounds.size.height -= (safeInsets.top + safeInsets.bottom)
        return bounds.clampedToPositiveSize()
    }

    /// Resolves the available layout rectangle by applying content insets to the layout bounds.
    ///
    /// - Parameters:
    ///   - bounds: The bounds produced by ``layoutBounds(for:layoutGuide:)``.
    ///   - contentInsets: Insets describing additional padding for the presented view.
    /// - Returns: A rectangle representing the final area available for layout calculations.
    func availableRect(within bounds: CGRect, contentInsets: UIEdgeInsets) -> CGRect {
        var rect = bounds
        rect.origin.x += contentInsets.left
        rect.origin.y += contentInsets.top
        rect.size.width -= (contentInsets.left + contentInsets.right)
        rect.size.height -= (contentInsets.top + contentInsets.bottom)
        return rect.clampedToPositiveSize()
    }

    /// Calculates the target size for the presented view based on the layout configuration.
    ///
    /// - Parameters:
    ///   - view: The view that should be presented.
    ///   - layoutGuide: The layout guide describing sizing behaviour.
    ///   - availableRect: The rectangle available for layout.
    ///   - containerSize: The raw size of the container view (prior to safe-area adjustments).
    ///   - widthLimit: An optional upper bound for the resulting width.
    ///   - heightLimit: An optional upper bound for the resulting height.
    /// - Returns: The resolved size that should be applied to the presented view.
    func resolvedSize(
        for view: UIView,
        layoutGuide: LayoutGuide,
        availableRect: CGRect,
        containerSize: CGSize,
        widthLimit: CGFloat? = nil,
        heightLimit: CGFloat? = nil
    ) -> CGSize {
        let availableWidth = max(0, availableRect.width)
        let availableHeight = max(0, availableRect.height)

        let horizontalLimit = widthLimit.map { min($0, availableWidth) }
        let verticalLimit = heightLimit.map { min($0, availableHeight) }

        let horizontalDimension = LayoutDimensionConstraint.horizontal(
            rule: layoutGuide.width,
            availableLength: availableWidth,
            containerLength: containerSize.width,
            insetSum: layoutGuide.contentInsets.left + layoutGuide.contentInsets.right,
            limit: horizontalLimit
        )

        let verticalDimension = LayoutDimensionConstraint.vertical(
            rule: layoutGuide.height,
            availableLength: availableHeight,
            containerLength: containerSize.height,
            insetSum: layoutGuide.contentInsets.top + layoutGuide.contentInsets.bottom,
            limit: verticalLimit
        )

        let targetSize = CGSize(
            width: max(0, horizontalDimension.targetLength),
            height: max(0, verticalDimension.targetLength)
        )

        let measuredSize = view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalDimension.priority,
            verticalFittingPriority: verticalDimension.priority
        )

        var width = horizontalDimension.resolvedLength(
            measured: measuredSize.width,
            available: availableWidth
        )
        var height = verticalDimension.resolvedLength(
            measured: measuredSize.height,
            available: availableHeight
        )

        if width == 0 {
            width = fallbackLength(
                current: view.bounds.width,
                intrinsic: view.intrinsicContentSize.width,
                dimension: horizontalDimension,
                available: availableWidth
            )
        }

        if height == 0 {
            height = fallbackLength(
                current: view.bounds.height,
                intrinsic: view.intrinsicContentSize.height,
                dimension: verticalDimension,
                available: availableHeight
            )
        }

        return CGSize(width: width.roundedForLayout(), height: height.roundedForLayout())
    }

    /// Produces a fallback length when Auto Layout measurement returns zero.
    private func fallbackLength(
        current: CGFloat,
        intrinsic: CGFloat,
        dimension: LayoutDimensionConstraint,
        available: CGFloat
    ) -> CGFloat {
        let candidates: [CGFloat] = [current, intrinsic, dimension.targetLength, dimension.limit ?? 0, available]
        var resolved: CGFloat = 0
        for value in candidates where value.isFinite && value > 0 {
            resolved = value
            break
        }
        if resolved == 0 { return 0 }
        var length = resolved
        if let limit = dimension.limit {
            length = min(length, limit)
        }
        if dimension.clampToAvailable {
            length = min(length, available)
        }
        return length
    }
}

// MARK: - LayoutDimensionConstraint

@MainActor
private struct LayoutDimensionConstraint {

    enum Mode { case fixed, flexible, fractional }

    let targetLength: CGFloat
    let priority: UILayoutPriority
    let limit: CGFloat?
    let clampToAvailable: Bool
    let mode: Mode

    func resolvedLength(measured: CGFloat, available: CGFloat) -> CGFloat {
        var length: CGFloat
        switch mode {
        case .fixed:
            length = targetLength
        case .fractional:
            length = targetLength
        case .flexible:
            let measurement = measured.isFinite && measured > 0 ? measured : targetLength
            length = min(targetLength, measurement)
        }
        if let limit {
            length = min(length, limit)
        }
        if clampToAvailable {
            length = min(length, available)
        }
        return max(0, length)
    }

    static func horizontal(
        rule: Width,
        availableLength: CGFloat,
        containerLength: CGFloat,
        insetSum: CGFloat,
        limit: CGFloat?
    ) -> LayoutDimensionConstraint {
        switch rule {
        case let .fixed(value):
            return LayoutDimensionConstraint(
                targetLength: max(0, value - insetSum),
                priority: .required,
                limit: limit,
                clampToAvailable: false,
                mode: .fixed
            )
        case .flexible:
            let allowed = max(0, min(availableLength, limit ?? availableLength))
            return LayoutDimensionConstraint(
                targetLength: allowed,
                priority: .fittingSizeLevel,
                limit: allowed,
                clampToAvailable: true,
                mode: .flexible
            )
        case let .fractional(value):
            let raw = max(0, containerLength * value - insetSum)
            let allowed = max(0, min(limit ?? availableLength, availableLength))
            return LayoutDimensionConstraint(
                targetLength: raw,
                priority: .required,
                limit: allowed,
                clampToAvailable: true,
                mode: .fractional
            )
        }
    }

    static func vertical(
        rule: Height,
        availableLength: CGFloat,
        containerLength: CGFloat,
        insetSum: CGFloat,
        limit: CGFloat?
    ) -> LayoutDimensionConstraint {
        switch rule {
        case let .fixed(value):
            return LayoutDimensionConstraint(
                targetLength: max(0, value - insetSum),
                priority: .required,
                limit: limit,
                clampToAvailable: false,
                mode: .fixed
            )
        case .flexible:
            let allowed = max(0, min(availableLength, limit ?? availableLength))
            return LayoutDimensionConstraint(
                targetLength: allowed,
                priority: .fittingSizeLevel,
                limit: allowed,
                clampToAvailable: true,
                mode: .flexible
            )
        case let .fractional(value):
            let raw = max(0, containerLength * value - insetSum)
            let allowed = max(0, min(limit ?? availableLength, availableLength))
            return LayoutDimensionConstraint(
                targetLength: raw,
                priority: .required,
                limit: allowed,
                clampToAvailable: true,
                mode: .fractional
            )
        }
    }
}

// MARK: - Internal utilities

private extension CGRect {
    func clampedToPositiveSize() -> CGRect {
        var rect = standardized
        if rect.size.width < 0 {
            rect.size.width = 0
        }
        if rect.size.height < 0 {
            rect.size.height = 0
        }
        return rect
    }

}

private extension CGFloat {
    func roundedForLayout() -> CGFloat {
        guard isFinite else { return 0 }
        let scale = UIScreen.main.scale
        guard scale.isFinite && scale > 0 else { return self }
        return (self * scale).rounded() / scale
    }
}
