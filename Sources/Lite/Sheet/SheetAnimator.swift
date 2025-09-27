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
internal struct SheetAnimator: AlertbleAnimator {

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
    /// below the screen while fading out the dimming view. The animation provides
    /// visual feedback during the dismissal process.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to execute when the animation completes.
    func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        context.presentedView.layoutIfNeeded()
        let height = context.frame.height - context.presentedView.frame.minY

        withSpringTimingAnimation {
            context.dimmingView.alpha = 0
            context.presentedView.alpha = 0.5
            context.presentedView.transform = CGAffineTransform(translationX: 0, y: height)
        } completion: { _ in
            completion()
        }
    }
}
