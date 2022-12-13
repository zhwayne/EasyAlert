//
//  Alertble.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

public protocol Alertble : AlertDismissible {
    
    var isShowing: Bool { get }
    
    @MainActor func show(in view: UIView?)
}

public extension Alertble {
    
    @MainActor func show(in viewController: UIViewController) {
        show(in: viewController.view)
    }
}
