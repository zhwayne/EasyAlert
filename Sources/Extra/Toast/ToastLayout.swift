//
//  ToastLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

/// A layout manager that handles the positioning and sizing of toast notifications.
///
/// `ToastLayout` implements the `AlertableLayout` protocol to provide flexible
/// layout management for toast notifications. It supports both center and bottom
/// positioning with responsive sizing based on content and screen dimensions.
final class ToastLayout: AlertableLayout {

    /// The position where the toast should be displayed on the screen.
    ///
    /// This property determines whether the toast appears in the center or at the
    /// bottom of the screen, affecting the frame calculation below.
    var position: Toast.Position = .bottom

    /// Updates the layout of the toast view based on the provided context and layout guide.
    ///
    /// The toast layout now relies on frame calculations. The presented view is measured
    /// using Auto Layout and positioned either at the vertical center or above the bottom
    /// edge with a proportional offset to mimic the previous constraint-based behaviour,
    /// returning the final frame without mutating constraints directly.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to be laid out.
    ///   - layoutGuide: The layout guide that defines sizing and positioning constraints.
    /// - Returns: The frame that should be applied to the toast view.
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

        let originX = available.minX + (available.width - size.width) * 0.5
        let originY: CGFloat

        switch position {
        case .center:
            originY = available.minY + (available.height - size.height) * 0.5

        case .bottom:
            // FIXME: 横屏和竖屏场景下，toast 底部的高度应定由当前设备方向高度重新计算
            let containerHeight = context.containerView.bounds.height
            let bottomOffset = containerHeight * 0.15
            originY = available.maxY - bottomOffset - size.height
        }

        return CGRect(origin: CGPoint(x: originX, y: originY), size: size)
    }
}
