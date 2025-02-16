//
//  MyAlertActionLayout.swift
//  EasyAlert_Example
//
//  Created by iya on 2022/5/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EasyAlert

struct MyAlertActionLayout : ActionLayout {
    
    var prefersSeparatorHidden: Bool { true }
    
    private let stackView: UIStackView
    
    init() {
        stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 16
    }

    func layout(views: [UIView], container: UIView) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        views.forEach { stackView.addArrangedSubview($0) }
        stackView.axis = views.count <= 3 ? .horizontal : .vertical
        
        NSLayoutConstraint.deactivate(stackView.constraints)
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 0).isActive = true
        stackView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16).isActive = true
        stackView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -16).isActive = true
    }
}
