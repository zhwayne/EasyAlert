//
//  TransitionAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

/// A protocol for objects that can perform transition animations for an alert.
@MainActor public protocol TransitionAnimator {
    /// Performs the animation for showing the alert.
    mutating func show(with context: TransitionContext, completion: @escaping () -> Void)
    
    /// Performs the animation for dismissing the alert.
    mutating func dismiss(with context: TransitionContext, completion: @escaping () -> Void)
    
    /// Updates the layout of the alert during the transition.
    mutating func update(with context: TransitionContext)
}
