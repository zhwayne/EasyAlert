//
//  AlertAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

/// An animator that provides standard show and dismiss animations for alerts.
///
/// `AlertAnimator` implements the `AlertbleAnimator` protocol to provide
/// smooth, spring-based animations for alert presentation and dismissal.
/// The animations include a subtle scale effect for the alert content and
/// fade effects for both the content and backdrop.
internal struct AlertAnimator: AlertbleAnimator {

    /// Animates the presentation of the alert with a spring-based scale and fade effect.
    ///
    /// The animation starts with the alert content scaled up to 120% and fully transparent,
    /// then animates to normal scale and full opacity. The backdrop also fades in from
    /// transparent to opaque, creating a smooth presentation effect.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to execute when the animation completes.
    func show(context: LayoutContext, completion: @escaping () -> Void) {
        // Set initial state for the animation
        context.presentedView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        context.presentedView.alpha = 0
        context.dimmingView.alpha = 0

        // Animate to final state with spring timing
        withSpringTimingAnimation {
            context.dimmingView.alpha = 1
            context.presentedView.alpha = 1
            context.presentedView.transform = .identity
        } completion: { _ in
            completion()
        }
    }

    /// Animates the dismissal of the alert with a fade-out effect.
    ///
    /// The animation fades out both the alert content and backdrop to transparent,
    /// creating a smooth dismissal effect without any scaling or movement.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to execute when the animation completes.
    func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        withSpringTimingAnimation {
            context.presentedView.alpha = 0
            context.dimmingView.alpha = 0
        } completion: { _ in
            completion()
        }
    }
    

}

