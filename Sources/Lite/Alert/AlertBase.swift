//
//  File.swift
//  
//
//  Created by iya on 2024/5/17.
//

import Foundation
import UIKit

/// An enumeration representing the width of an alert.
public enum Width: Equatable {
    
    /// A fixed width equal to the specified value.
    case fixed(CGFloat)
    
    /// A flexible width that can grow up to the specified value.
    case flexible(CGFloat)
    
    /// A width that is a multiple of the superview's width, but less than the specified maximum width.
    case multiplied(by: CGFloat, maximumWidth: CGFloat? = nil)
}

/// An enumeration representing the height of an alert.
public enum Height: Equatable {
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
public struct LayoutGuide: Equatable {
    /// The width of the alert.
    public var width: Width = .fixed(280)
    
    /// The height of the alert.
    public var height: Height = .automatic
    
    /// The edge insets of the alert.
    public var contentInsets: UIEdgeInsets = .zero
    
    /// Creates a new `LayoutGuide` with the specified width, height, and edge insets.
    public init(width: Width = .fixed(280), height: Height = .automatic, contentInsets: UIEdgeInsets = .zero) {
        self.width = width
        self.height = height
        self.contentInsets = contentInsets
    }
}

/// A context object for use during the transition animation of an alert.
public struct TransitionContext {
    /// The size of the space occupied by the alert.
    public let size: CGSize
    
    /// The dimming view for the alert.
    public let dimmingView: UIView
    
    /// The view that contains the custom alert view.
    public let container: UIView
    
    /// The current interface orientation.
    public let interfaceOrientation: UIInterfaceOrientation
    
    /// The layout for this alert.
    public let layoutGuide: LayoutGuide
}
