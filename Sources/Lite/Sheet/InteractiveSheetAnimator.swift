//
//  InteractiveSheetAnimator.swift
//  EasyAlert
//
//  Created by Assistant on 2024/12/19.
//

import UIKit

/// An enhanced sheet animator that supports interactive progress updates.
///
/// `InteractiveSheetAnimator` extends the base `SheetAnimator` to provide interactive
/// animation control through the `InteractiveAnimator` protocol. It uses `UIViewPropertyAnimator`
/// to enable real-time progress updates during user gestures, allowing for smooth
/// drag-to-dismiss interactions.
internal final class InteractiveSheetAnimator: SheetAnimator, InteractiveAnimator {
    
    /// The current property animator for interactive progress updates.
    private var currentAnimator: UIViewPropertyAnimator?
    
    /// Updates the animation progress for interactive animations.
    ///
    /// This method provides real-time visual feedback during drag gestures,
    /// allowing the sheet to respond smoothly to user interactions.
    ///
    /// - Parameter progress: The animation progress from 0.0 to 1.0.
    /// - Returns: `true` if the progress was updated, `false` otherwise.
    @discardableResult
    func updateProgress(_ progress: CGFloat) -> Bool {
        guard let animator = currentAnimator else { return false }
        
        let clampedProgress = max(0, min(1, progress))
        animator.fractionComplete = clampedProgress
        return true
    }
    
    /// Performs the animation for showing the alert with interactive support.
    ///
    /// This method creates a `UIViewPropertyAnimator` that can be controlled
    /// interactively through the `updateProgress` method, enabling smooth
    /// gesture-driven animations.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to call when the animation completes.
    override func show(context: LayoutContext, completion: @escaping () -> Void) {
        let height = context.presentedView.bounds.height + context.dimmingView.safeAreaInsets.bottom
        context.presentedView.transform = CGAffineTransform(translationX: 0, y: height)
        context.dimmingView.alpha = 0

        // Create property animator for interactive control
        currentAnimator = UIViewPropertyAnimator(
            duration: 1.0,
            timingParameters: UISpringTimingParameters()
        )
        
        currentAnimator?.addAnimations {
            context.dimmingView.alpha = 1
            context.presentedView.transform = .identity
        }
        
        currentAnimator?.addCompletion { _ in
            self.currentAnimator = nil
            completion()
        }
        
        currentAnimator?.startAnimation()
    }
    
    /// Performs the animation for dismissing the alert with interactive support.
    ///
    /// This method creates a `UIViewPropertyAnimator` that can be controlled
    /// interactively through the `updateProgress` method, enabling smooth
    /// gesture-driven dismissal animations.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to call when the animation completes.
    override func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        context.presentedView.layoutIfNeeded()
        let height = context.containerView.frame.height - context.presentedView.frame.minY

        // Create property animator for interactive control
        currentAnimator = UIViewPropertyAnimator(
            duration: 1.0,
            timingParameters: UISpringTimingParameters()
        )
        
        currentAnimator?.addAnimations {
            context.dimmingView.alpha = 0
            context.presentedView.alpha = 0.5
            context.presentedView.transform = CGAffineTransform(translationX: 0, y: height)
        }
        
        currentAnimator?.addCompletion { _ in
            self.currentAnimator = nil
            completion()
        }
        
        currentAnimator?.startAnimation()
    }
}
