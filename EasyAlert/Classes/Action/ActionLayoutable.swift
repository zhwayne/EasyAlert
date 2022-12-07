//
//  ActionLayoutable.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import Foundation

public protocol ActionLayoutable {
    
    var prefersSeparatorHidden: Bool { get }
    
    func layout(actionViews: [UIView], container: UIView)
    
    init() 
}

public extension ActionLayoutable {
    
    var prefersSeparatorHidden: Bool { true }
}
