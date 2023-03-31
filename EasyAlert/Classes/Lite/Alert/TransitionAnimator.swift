//
//  TransitionAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

/// An enumeration representing the width of an alert.
public enum Width {
    /// A fixed width equal to the specified value.
    case fixed(CGFloat)
    
    /// A flexible width that can grow up to the specified value.
    case flexible(CGFloat)
    
    /// A width that is a multiple of the superview's width, but less than the specified maximum width.
    case multiplied(_ by: CGFloat, maximumWidth: CGFloat = 0)
}

/// An enumeration representing the height of an alert.
public enum Height {
    /// The height is determined entirely by the content of the alert.
    case automatic
    
    /// The height is greater than or equal to the specified value.
    case greaterThanOrEqualTo(CGFloat)
}

/// A guide for describing the layout of an alert.
public struct LayoutGuide {
    /// The width of the alert.
    public var width: Width
    
    /// The height of the alert.
    public var height: Height = .automatic
    
    /// The edge insets of the alert.
    public var edgeInsets: UIEdgeInsets = .zero
    
    /// Creates a new `LayoutGuide` with the specified width, height, and edge insets.
    public init(width: Width, height: Height = .automatic, edgeInsets: UIEdgeInsets = .zero) {
        self.width = width
        self.height = height
        self.edgeInsets = edgeInsets
    }
}

/// A context object for use during the transition animation of an alert.
public struct TransitionContext {
    /// The view that contains the custom alert view.
    public let container: UIView
    
    /// The backdrop view for the alert.
    public let backdropView: UIView
    
    /// The dimming view for the alert.
    public let dimmingView: UIView
    
    /// The current interface orientation.
    public let interfaceOrientation: UIInterfaceOrientation
    
    /// The frame of the backdrop view.
    public var frame: CGRect { backdropView.bounds }
}

/// A protocol for objects that can perform transition animations for an alert.
public protocol TransitionAnimator {
    /// Performs the animation for showing the alert.
    mutating func show(context: TransitionContext, completion: @escaping () -> Void)
    
    /// Performs the animation for dismissing the alert.
    mutating func dismiss(context: TransitionContext, completion: @escaping () -> Void)
    
    /// Updates the layout of the alert during the transition.
    mutating func update(context: TransitionContext, layoutGuide: LayoutGuide)
}

@available(iOS 13.0, *)
extension TransitionAnimator {
    /// An asynchronous version of `show(context:completion:)` that suspends until the animation is complete.
    @MainActor
    mutating func show(context: TransitionContext) async {
        await withUnsafeContinuation({ continuation in
            show(context: context) {
                continuation.resume()
            }
        })
    }
    
    /// An asynchronous version of `dismiss(context:completion:)` that suspends until the animation is complete.
    @MainActor
    mutating func dismiss(context: TransitionContext) async {
        await withUnsafeContinuation({ continuation in
            dismiss(context: context) {
                continuation.resume()
            }
        })
    }
}
