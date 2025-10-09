//
//  SheetLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

/// A layout manager that handles the positioning and sizing of sheet presentations.
///
/// `SheetLayout` implements the `AlertableLayout` protocol to provide flexible
/// layout management for sheet presentations. It supports various sizing options
/// and positions sheets at the bottom of the screen with proper safe area handling.
final class SheetLayout: AlertableLayout {

    /// Updates the layout of the sheet view based on the provided context and layout guide.
    ///
    /// The sheet layout uses a frame-based system that measures the presented view
    /// and positions it along the bottom edge of the container. When running in
    /// landscape mode, the layout constrains the maximum width to match the original
    /// constraint-based implementation (414pt cap), and returns the final frame instead
    /// of mutating constraints.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to be laid out.
    ///   - layoutGuide: The layout guide that defines sizing and positioning constraints.
    /// - Returns: The frame that should be applied to the presented sheet view.
    func frameOfPresentedView(context: LayoutContext, layoutGuide: LayoutGuide) -> CGRect {
        let presentedView = context.presentedView

        let bounds = layoutBounds(for: context, layoutGuide: layoutGuide)
        let available = availableRect(within: bounds, contentInsets: layoutGuide.contentInsets)
        let widthLimit = context.interfaceOrientation.isLandscape ? CGFloat(414) : nil
        let size = resolvedSize(
            for: presentedView,
            layoutGuide: layoutGuide,
            availableRect: available,
            containerSize: context.containerView.bounds.size,
            widthLimit: widthLimit
        )

        let safeInsets = context.containerView.safeAreaInsets
        let containerBounds = context.containerView.bounds
        
        let finalHeight: CGFloat
        let originY: CGFloat
        
        // 根据 LayoutGuide.edgesForExtendedSafeArea 是否包含 .bottom 决定底部行为
        if layoutGuide.edgesForExtendedSafeArea.contains(.bottom) {
            // 紧贴底部：高度包含安全区域，位置从容器底部开始
            finalHeight = min(containerBounds.height, size.height + safeInsets.bottom)
            originY = containerBounds.maxY - finalHeight - layoutGuide.contentInsets.bottom
        } else {
            // 底部留白：高度不包含安全区域，位置考虑安全区域
            finalHeight = min(containerBounds.height - safeInsets.bottom, size.height)
            originY = containerBounds.maxY - safeInsets.bottom - finalHeight - layoutGuide.contentInsets.bottom
        }

        let origin = CGPoint(
            x: available.minX + (available.width - size.width) * 0.5,
            y: originY
        )

        return CGRect(origin: origin, size: CGSize(width: size.width, height: finalHeight))
    }
}
