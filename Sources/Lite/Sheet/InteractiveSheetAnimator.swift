//
//  InteractiveSheetAnimator.swift
//  EasyAlert
//
//  Created by Assistant on 2024/12/19.
//

import UIKit

/// A custom animator for InteractiveSheet that can access drag state.
///
/// `InteractiveSheetAnimator` extends the base `AlertbleAnimator` protocol to provide
/// specialized animation behavior for interactive sheets. It can access the current
/// drag translation state to ensure smooth dismissal animations from the current
/// drag position rather than the original position.
internal class InteractiveSheetAnimator: AlertbleAnimator {
    
    /// A weak reference to the interactive sheet to access drag state.
    private weak var interactiveSheet: InteractiveSheet?
    
    /// Creates a new interactive sheet animator.
    ///
    /// - Parameter interactiveSheet: The interactive sheet that this animator will animate.
    init(interactiveSheet: InteractiveSheet) {
        self.interactiveSheet = interactiveSheet
    }
    
    /// Animates the sheet into view with a slide-up animation.
    ///
    /// This method provides the same entrance animation as the standard `SheetAnimator`,
    /// starting from below the screen and sliding up to its final position.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to execute when the animation completes.
    func show(context: LayoutContext, completion: @escaping () -> Void) {
        let height = context.presentedView.bounds.height + context.dimmingView.safeAreaInsets.bottom
        context.presentedView.transform = CGAffineTransform(translationX: 0, y: height)
        context.dimmingView.alpha = 0

        withSpringTimingAnimation {
            context.dimmingView.alpha = 1
            context.presentedView.transform = .identity
        } completion: { _ in
            completion()
        }
    }
    
    /// Animates the sheet out of view with a slide-down animation.
    ///
    /// This method creates a smooth exit animation for the sheet, taking into account
    /// the current drag position. If the user has dragged the sheet, the animation
    /// starts from the current drag position rather than the original position.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to execute when the animation completes.
    func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        context.presentedView.layoutIfNeeded()
        
        // 获取拖拽偏移量
        let dragTranslationY = interactiveSheet?.currentDragTranslationY ?? 0.0
        
        // 计算从当前位置到屏幕底部的距离
        let currentMinY = context.presentedView.frame.minY + dragTranslationY
        let distanceToBottom = context.containerView.frame.height - currentMinY
        let height = distanceToBottom + context.dimmingView.safeAreaInsets.bottom

        withSpringTimingAnimation {
            context.dimmingView.alpha = 0
            context.presentedView.transform = CGAffineTransform(translationX: 0, y: height)
        } completion: { _ in
            completion()
        }
    }
}
