//
//  AlertableLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

@MainActor public enum Width {

    case fixed(CGFloat)

    case flexible

    case multiplied(by: CGFloat, maxWidth: CGFloat? = nil)
}

@MainActor public enum Height {

    case fixed(CGFloat)

    case flexible

    case greaterThanOrEqualTo(CGFloat)
}

@MainActor public struct LayoutGuide {

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
    func updateLayout(context: LayoutContext, layoutGuide: LayoutGuide)
}

/// A context object for use during the transition animation of an alert.
@MainActor public struct LayoutContext {
    /// The backdrop view for the alert.
    public let containerView: UIView

    /// The dimming view for the alert.
    public let dimmingView: UIView

    /// The view that contains the custom alert view.
    public let presentedView: UIView

    /// The current interface orientation.
    public let interfaceOrientation: UIInterfaceOrientation

    /// The frame of the backdrop view.
    public var frame: CGRect { containerView.bounds }
}
