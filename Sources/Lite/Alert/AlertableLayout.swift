//
//  AlertableLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

public enum Width: Sendable {
    
    case fixed(CGFloat)
    
    case flexible
    
    case multiplied(by: CGFloat, maxWidth: CGFloat? = nil)
}

public enum Height: Sendable {
    
    case fixed(CGFloat)
    
    case flexible
    
    case greaterThanOrEqualTo(CGFloat)
}

public struct AlertLayoutGuide: Sendable {

    public var width: Width
    
    public var height: Height
    
    public var contentInsets: UIEdgeInsets
    
    public var ignoresSafeAreaBottom: Bool
    
    public init(
        width: Width,
        height: Height,
        contentInsets: UIEdgeInsets = .zero,
        ignoresSafeAreaBottom: Bool = false
    ) {
        self.width = width
        self.height = height
        self.contentInsets = contentInsets
        self.ignoresSafeAreaBottom = ignoresSafeAreaBottom
    }
}


@MainActor public protocol AlertableLayout {
    
    /// Updates the layout of the alert during the transition.
    func updateLayout(context: LayoutContext, layoutGuide: AlertLayoutGuide)
}
