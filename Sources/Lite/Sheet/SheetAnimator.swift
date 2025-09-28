//
//  SheetAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

/// An animator that provides slide-up animations for sheet presentations.
///
/// `SheetAnimator` implements the `AlertbleAnimator` protocol to provide smooth,
/// spring-based slide-up animations for sheet presentations. It animates the sheet
/// from below the screen to its final position, creating a natural modal presentation.
/// It can also handle interactive drag-to-dismiss animations when provided with a sheet reference.
internal class SheetAnimator: AlertbleAnimator {
    
    /// A weak reference to the sheet to access drag state for interactive animations.
    private weak var sheet: Sheet?
    
    /// Creates a new sheet animator.
    ///
    /// - Parameter sheet: Optional sheet reference for interactive animations.
    init(sheet: Sheet? = nil) {
        self.sheet = sheet
    }

    /// Animates the sheet into view with a slide-up animation.
    ///
    /// This method creates a smooth entrance animation for the sheet, starting from
    /// below the screen and sliding up to its final position. The dimming view
    /// fades in simultaneously to provide proper visual context.
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
    /// This method creates a smooth exit animation for the sheet, sliding it down
    /// below the screen while fading out the dimming view. For interactive sheets,
    /// it takes into account the current drag position to ensure smooth animations
    /// from the current position rather than the original position.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to execute when the animation completes.
    func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        context.presentedView.layoutIfNeeded()
        
        // Check if this is an interactive sheet with drag state
        if let sheet = sheet, sheet.isInteractive {
            // Use drag translation for interactive sheets
            let dragTranslationY = sheet.currentDragTranslationY
            let currentMinY = context.presentedView.frame.minY + dragTranslationY
            let distanceToBottom = context.containerView.frame.height - currentMinY
            let height = distanceToBottom + context.dimmingView.safeAreaInsets.bottom
            
            withSpringTimingAnimation {
                context.dimmingView.alpha = 0
                context.presentedView.transform = CGAffineTransform(translationX: 0, y: height)
            } completion: { _ in
                completion()
            }
        } else {
            // Use standard animation for non-interactive sheets
            let distanceToBottom = context.containerView.frame.height - context.presentedView.frame.minY
            let height = distanceToBottom + context.dimmingView.safeAreaInsets.bottom
            
            withSpringTimingAnimation {
                context.dimmingView.alpha = 0
                context.presentedView.transform = CGAffineTransform(translationX: 0, y: height)
            } completion: { _ in
                completion()
            }
        }
    }
    
}
