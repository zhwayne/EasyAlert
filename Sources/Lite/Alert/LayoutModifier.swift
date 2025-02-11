//
//  LayoutModifier.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
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
    public var width: Width
    
    /// The height of the alert.
    public var height: Height
    
    /// The edge insets of the alert.
    public var contentInsets: UIEdgeInsets
    
    /// Creates a new `LayoutGuide` with the specified width, height, and edge insets.
    public init(width: Width = .fixed(270), height: Height = .automatic, contentInsets: UIEdgeInsets = .zero) {
        self.width = width
        self.height = height
        self.contentInsets = contentInsets
    }
}


@MainActor public protocol LayoutModifier {
    
    /// Updates the layout of the alert during the transition.
    func update(context: LayoutContext, layoutGuide: LayoutGuide)
}
