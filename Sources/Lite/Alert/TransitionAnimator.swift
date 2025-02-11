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
    func show(context: LayoutContext, completion: @escaping () -> Void)
    
    /// Performs the animation for dismissing the alert.
    func dismiss(context: LayoutContext, completion: @escaping () -> Void)
}
