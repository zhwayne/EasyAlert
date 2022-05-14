//
//  AlertLayoutable.swift
//  EasyAlert
//
//  Created by iya on 2021/12/9.
//

import Foundation

public extension Alert {
    enum Width {
        case fixed(CGFloat)
        case flexible(CGFloat)
        case multiplied(CGFloat)
    }
}

public protocol AlertLayoutable {
    
    var width: Alert.Width { get set }
    
    func layout(content: Alert.CustomizedView, container: UIView, interfaceOrientation: UIInterfaceOrientation)
}
