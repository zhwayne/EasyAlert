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
    
    enum Height {
        case automic
        case greaterThanOrEqualTo(CGFloat)
    }
}

public struct AlertLayoutContext {
    
    let container: UIView
    
    let interfaceOrientation: UIInterfaceOrientation
    
    let frame: CGRect

    let keyboardFrame: CGRect?    
}

public protocol AlertLayoutable {
    
    var width: Alert.Width { get set }
    
    var height: Alert.Height { get set }
        
    func layout(with context: AlertLayoutContext)
}
