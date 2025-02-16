//
//  MySheetActionLayout.swift
//  EasyAlert_Example
//
//  Created by xxx on 2024/1/11.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import EasyAlert

struct MySheetActionLayout: ActionLayout {
    
    var prefersSeparatorHidden: Bool { true }
    
    private let stackView: UIStackView
    
    private var constraints: [NSLayoutConstraint] = []
    
    init() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    mutating func layout(views: [UIView], container: UIView) {
        
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        defer { NSLayoutConstraint.activate(constraints) }
        
        stackView.subviews.forEach { $0.removeFromSuperview() }
        views.forEach { stackView.addArrangedSubview($0) }
        container.addSubview(stackView)
        
        constraints.append(stackView.topAnchor.constraint(equalTo: container.topAnchor))
        constraints.append(stackView.leftAnchor.constraint(equalTo: container.leftAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor))
        constraints.append(stackView.rightAnchor.constraint(equalTo: container.rightAnchor))
    }
}
