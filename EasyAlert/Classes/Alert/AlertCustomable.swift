//
//  AlertCustomable.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

public protocol AlertCustomable: AnyObject {}

public extension AlertCustomable where Self: UIView {
    
    func dismiss(completion: (() -> Void)? = nil) {
        for view in sequence(first: superview, next: { $0?.superview }) {
            if let backgroundView = view as? TransitionView {
                backgroundView.alert?.dismiss(completion: completion)
            }
        }
    }
}
