//
//  AlertbleAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

/// A protocol for objects that can perform transition animations for an alert.
///
/// `AlertbleAnimator` defines the interface for customizing alert presentation and
/// dismissal animations. Each animator should focus on implementing a specific
/// animation style. For different animation types, create separate implementations.
@MainActor public protocol AlertbleAnimator {
    
    /// Performs the animation for showing the alert.
    ///
    /// This method is called when the alert is about to be presented. The animator
    /// should set up the initial state of the views and then animate them to their
    /// final presentation state.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to call when the animation completes.
    func show(context: LayoutContext, completion: @escaping () -> Void)
    
    /// Performs the animation for dismissing the alert.
    ///
    /// This method is called when the alert is about to be dismissed. The animator
    /// should animate the views from their current state to their dismissal state.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to animate.
    ///   - completion: A closure to call when the animation completes.
    func dismiss(context: LayoutContext, completion: @escaping () -> Void)
}
