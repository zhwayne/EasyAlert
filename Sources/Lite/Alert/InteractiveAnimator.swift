//
//  InteractiveAnimator.swift
//  EasyAlert
//
//  Created by Assistant on 2024/12/19.
//

import UIKit

/// A protocol for animators that support interactive progress updates.
///
/// `InteractiveAnimator` extends the basic animation capabilities with interactive
/// progress control, allowing animations to be driven by user gestures or other
/// interactive elements. This protocol should be implemented by animators that
/// need to respond to real-time user input during animations.
@MainActor public protocol InteractiveAnimator: AlertbleAnimator {
    
    /// Updates the animation progress for interactive animations.
    ///
    /// This method provides real-time visual feedback during interactive gestures,
    /// allowing the animation to respond smoothly to user interactions. The progress
    /// value typically ranges from 0.0 (animation start) to 1.0 (animation end).
    ///
    /// - Parameter progress: The animation progress from 0.0 to 1.0.
    /// - Returns: `true` if the progress was updated successfully, `false` if the
    ///   animator doesn't currently support interactive updates or no animation is running.
    @discardableResult
    func updateProgress(_ progress: CGFloat) -> Bool
}

// MARK: - Default Implementation

/// Provides a default implementation that returns `false` for non-interactive animators.
@MainActor public extension InteractiveAnimator {
    
    @discardableResult
    func updateProgress(_ progress: CGFloat) -> Bool {
        return false
    }
}
