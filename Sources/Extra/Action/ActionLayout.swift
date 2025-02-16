//
//  ActionLayout.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

public protocol ActionLayout {
    
    var prefersSeparatorHidden: Bool { get }
    
    mutating func layout(views: [UIView], container: UIView)
    
    init() 
}

public extension ActionLayout {
    
    var prefersSeparatorHidden: Bool { false }
}

public extension ActionLayout {
    
    func generateSeparatorView() -> UIView {
        ActionVibrantSeparatorView()
    }
}
