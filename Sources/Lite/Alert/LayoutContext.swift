//
//  LayoutContext.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

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
