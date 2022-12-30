//
//  TransitionCoordinator.swift
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

public struct TransitionCoordinatorContext {
    
    public let container: UIView
    
    public let backdropView: UIView
        
    public let dimmingView: UIView
    
    public let interfaceOrientation: UIInterfaceOrientation
    
    /// The bounds of backdropView
    public var frame: CGRect { backdropView.bounds }
}

public protocol TransitionCoordinator {
    
    /* var duration: TimeInterval { get set } */

    var layoutGuide: LayoutGuide { get set }
    
    mutating func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void)
    
    mutating func dismiss(context: TransitionCoordinatorContext, completion: @escaping () -> Void)
    
    mutating func update(context: TransitionCoordinatorContext)
}

@available(iOS 13.0, *)
extension TransitionCoordinator {
    
    @MainActor
    mutating func show(context: TransitionCoordinatorContext) async {
        await withUnsafeContinuation({ continuation in
            show(context: context) {
                continuation.resume()
            }
        })
    }
    
    @MainActor
    mutating func dismiss(context: TransitionCoordinatorContext) async {
        await withUnsafeContinuation({ continuation in
            dismiss(context: context) {
                continuation.resume()
            }
        })
    }
}
