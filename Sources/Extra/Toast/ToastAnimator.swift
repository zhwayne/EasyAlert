//
//  ToastAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

/// An animator that provides spring-based animations for toast notifications.
///
/// `ToastAnimator` implements the `AlertbleAnimator` protocol to provide smooth,
/// spring-based animations for showing and dismissing toast notifications. It uses
/// a scale and fade animation that creates a polished user experience.
internal struct ToastAnimator: AlertbleAnimator {

    /// Animates the toast into view with a spring-based scale and fade animation.
    ///
    /// This method creates a smooth entrance animation for the toast, starting from
    /// a slightly scaled-down and transparent state and animating to full opacity
    /// and normal scale using spring timing for natural motion.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to execute when the animation completes.
    func show(context: LayoutContext, completion: @escaping () -> Void) {
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        context.presentedView.transform = transform
        context.presentedView.alpha = 0

        withSpringTimingAnimation {
            context.presentedView.alpha = 1
            context.presentedView.transform = .identity
        } completion: { _ in
            completion()
        }
    }

    /// Animates the toast out of view with a spring-based scale and fade animation.
    ///
    /// This method creates a smooth exit animation for the toast, animating from
    /// full opacity and normal scale to a slightly scaled-down and transparent state
    /// using spring timing for natural motion.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to execute when the animation completes.
    func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        withSpringTimingAnimation {
            context.presentedView.alpha = 0
            context.presentedView.transform = transform
        } completion: { _ in
            completion()
        }
    }
}
