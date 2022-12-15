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
    
    var isShowing: Bool { get }
    
    func show(in container: AlertContainerable?)
}
