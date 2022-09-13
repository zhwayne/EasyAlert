//
//  ActionLayoutable.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import Foundation
import SnapKit

public protocol ActionLayoutable {
    
    func layout(actionViews: [UIView], container: UIView)
}
