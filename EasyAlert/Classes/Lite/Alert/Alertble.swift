//
//  Alertble.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

public protocol AlertContainerable: AnyObject { }

extension UIView: AlertContainerable { }

extension UIViewController: AlertContainerable { }

public protocol Alertble : AlertDismissible {
    
    /// A value that marks whether an alert is being displayed.
    var isShowing: Bool { get }
    
    /// Show alert in the container.
    /// - Parameter container: An instance of a `UIView` or `UIViewController` that implements the
    /// `AlertContainerable`.
    func show(in container: AlertContainerable?)
}
