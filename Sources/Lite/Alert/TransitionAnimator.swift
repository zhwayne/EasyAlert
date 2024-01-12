//
//  TransitionAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

/// An enumeration representing the width of an alert.
public enum Width {
    
    /// A fixed width equal to the specified value.
    case fixed(CGFloat)
    
    /// A flexible width that can grow up to the specified value.
    case flexible(CGFloat)
    
    /// A width that is a multiple of the superview's width, but less than the specified maximum width.
    case multiplied(by: CGFloat, maximumWidth: CGFloat? = nil)
}

/// An enumeration representing the height of an alert.
public enum Height {
    /// The height is determined entirely by the content of the alert.
    case automatic
    
    /// A fixed height equal to the specified value.
    case fixed(CGFloat)
    
    /// A flexible height that can grow up to the specified value.
    case flexible(CGFloat)
    
    /// The height is greater than or equal to the specified value.
    case greaterThanOrEqualTo(CGFloat)
    
    /// A height that is a multiple of the superview's height, but less than the specified maximum height.
    case multiplied(by: CGFloat, maximumHeight: CGFloat? = nil)
}

/// A guide for describing the layout of an alert.
public struct LayoutGuide {
    /// The width of the alert.
    public var width: Width = .fixed(270)
    
    /// The height of the alert.
    public var height: Height = .automatic
    
    /// The edge insets of the alert.
    public var contentInsets: UIEdgeInsets = .zero
    
    /// Creates a new `LayoutGuide` with the specified width, height, and edge insets.
    public init(width: Width = .fixed(270), height: Height = .automatic, contentInsets: UIEdgeInsets = .zero) {
        self.width = width
        self.height = height
        self.contentInsets = contentInsets
    }
}

/// A context object for use during the transition animation of an alert.
public struct TransitionContext {
    /// The backdrop view for the alert.
    public let backdropView: UIView
    
    /// The dimming view for the alert.
    public let dimmingView: UIView
  
    /// The view that contains the custom alert view.
    public let container: UIView
    
    /// The current interface orientation.
    public let interfaceOrientation: UIInterfaceOrientation
    
    /// The frame of the backdrop view.
    public var frame: CGRect { backdropView.bounds }
}

/// A protocol for objects that can perform transition animations for an alert.
@MainActor public protocol TransitionAnimator {
    /// Performs the animation for showing the alert.
    mutating func show(context: TransitionContext, completion: @escaping () -> Void)
    
    /// Performs the animation for dismissing the alert.
    mutating func dismiss(context: TransitionContext, completion: @escaping () -> Void)
    
    /// Updates the layout of the alert during the transition.
    mutating func update(context: TransitionContext, layoutGuide: LayoutGuide)
}
