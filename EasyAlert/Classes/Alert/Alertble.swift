//
//  Alertble.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

public protocol Alertble : AnyObject {
    
    func show(in view: UIView?)
    
    func dismiss(completion: (() -> Void)?)
}

public protocol ActionAlertble: Alertble {
    
    func add(action: Action)
    
    func add(actions: [Action])
}
