//
//  ContainerLayout.swift
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

public protocol ContainerLayout {
    
    var width: Alert.Width { get set }
    
    func updateLayout(container: UIView, content: UIView, interfaceOrientation: UIInterfaceOrientation)
}
