//
//  Alertble.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

public protocol Alertble : AlertDismissible {
    
    @MainActor func show(in view: UIView?)
}
