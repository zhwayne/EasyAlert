//
//  ActionCustomizable.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import Foundation

public protocol ActionCustomizable : AlertDismissible {
 
    var title: String? { get set }
        
    var style: Action.Style { get }
    
    init(style: Action.Style)
}
