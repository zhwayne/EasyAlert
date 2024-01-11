//
//  ActionLayoutable.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

public protocol ActionLayoutable {
    
    var prefersSeparatorHidden: Bool { get }
    
    mutating func layout(views: [UIView], container: UIView)
    
    init() 
}

public extension ActionLayoutable {
    
    var prefersSeparatorHidden: Bool { false }
}

public extension ActionLayoutable {
    
    func generateSeparatorView() -> UIView {
        ActionVibrantSeparatorView()
    }
}
