//
//  AlertLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

/// A layout manager that handles the positioning and sizing of alert views.
///
/// `AlertLayout` implements the `AlertableLayout` protocol to provide standard
/// layout behavior for alerts, including width, height, and positioning constraints.
/// It supports flexible, fixed, and proportional sizing with proper constraint management.
final class AlertLayout: AlertableLayout {

    /// Updates the layout of the alert based on the provided context and layout guide.
    ///
    /// This method calculates the alert frame using a frame-based layout system. It
    /// resolves the available region, measures the presented view with Auto Layout,
    /// and returns the resulting frame instead of mutating constraints directly.
    ///
    /// - Parameters:
    ///   - context: The layout context containing views and layout information.
    ///   - layoutGuide: The layout guide that defines size and positioning constraints.
    /// - Returns: The frame that should be applied to the presented view.
    func frameOfPresentedView(context: LayoutContext, layoutGuide: LayoutGuide) -> CGRect {
        let presentedView = context.presentedView

        let bounds = layoutBounds(for: context, layoutGuide: layoutGuide)
        let available = availableRect(within: bounds, contentInsets: layoutGuide.contentInsets)

        let size = resolvedSize(
            for: presentedView,
            layoutGuide: layoutGuide,
            availableRect: available,
            containerSize: context.containerView.bounds.size
        )

        let origin = CGPoint(
            x: available.minX + (available.width - size.width) * 0.5,
            y: available.minY + (available.height - size.height) * 0.5
        )

        return CGRect(origin: origin, size: size)
    }
}
