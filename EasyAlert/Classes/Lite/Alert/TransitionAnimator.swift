//
//  TransitionAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

/// The width of an alert.
public enum Width {
    /// equal to value.
    case fixed(CGFloat)
    
    /// less than or equal to value.
    case flexible(CGFloat)
    
    /// multiples of superview's width but less than the `maximumWidth`.
    case multiplied(CGFloat, maximumWidth: CGFloat = 0)
}

/// The height of an alert.
public enum Height {
    
    /// Height is determined entirely by content
    case automic
    
    case greaterThanOrEqualTo(CGFloat)
}

/// A guide for describing the layout of an alert.
public struct LayoutGuide {
    
    /// The width of an alert.
    public var width: Width
    
    /// The height of an alert.
    public var height: Height
    
    /// The edge insets of an alert.
    public var edgeInsets: UIEdgeInsets
    
    public init(width: Width, height: Height = .automic, edgeInsets: UIEdgeInsets = .zero) {
        self.width = width
        self.height = height
        self.edgeInsets = edgeInsets
    }
}

public struct TransitionContext {
    
    /// The container that displays the custom view.
    public let container: UIView
    
    /// The backdrop view of this alert.
    public let backdropView: UIView
        
    /// The dimming view of this alert.
    public let dimmingView: UIView
    
    /// The current interface orientation.
    public let interfaceOrientation: UIInterfaceOrientation
    
    /// The bounds of backdropView
    public var frame: CGRect { backdropView.bounds }
}

public protocol TransitionAnimator {
    
    mutating func show(context: TransitionContext, completion: @escaping () -> Void)
    
    mutating func dismiss(context: TransitionContext, completion: @escaping () -> Void)
    
    mutating func update(context: TransitionContext, layoutGuide: LayoutGuide)
}

@available(iOS 13.0, *)
extension TransitionAnimator {
    
    @MainActor
    mutating func show(context: TransitionContext) async {
        await withUnsafeContinuation({ continuation in
            show(context: context) {
                continuation.resume()
            }
        })
    }
    
    @MainActor
    mutating func dismiss(context: TransitionContext) async {
        await withUnsafeContinuation({ continuation in
            dismiss(context: context) {
                continuation.resume()
            }
        })
    }
}
