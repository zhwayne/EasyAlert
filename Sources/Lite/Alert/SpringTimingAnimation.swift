//
//  SpringTimingAnimation.swift
//
//
//  Created by iya on 2024/1/9.
//

import UIKit

/// Performs an animation with spring timing parameters.
///
/// This function provides a convenient way to create spring-based animations
/// using `UIViewPropertyAnimator` with `UISpringTimingParameters`. The animation
/// uses a duration of 1 second with default spring parameters for a natural,
/// bouncy animation effect.
///
/// - Parameters:
///   - animations: A closure containing the animations to perform.
///   - completion: An optional closure to call when the animation completes.
///                 The closure receives a Boolean indicating whether the animation
///                 completed successfully (reached the end position).
@MainActor
func withSpringTimingAnimation(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
    let animator = UIViewPropertyAnimator(duration: 1, timingParameters: UISpringTimingParameters())
    animator.addAnimations(animations)
    if let completion {
        animator.addCompletion { position in
            completion(position == .end)
        }
    }
    animator.startAnimation()
}
