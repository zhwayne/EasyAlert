//
//  MyActionLayout.swift
//  EasyAlert_Example
//
//  Created by iya on 2022/5/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import EasyAlert

struct MyActionLayout : ActionLayoutable {

    func layout(actionViews: [UIView], container: UIView) {

        let stackView = UIStackView(arrangedSubviews: actionViews)
        stackView.axis = actionViews.count <= 3 ? .horizontal : .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        container.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 0).isActive = true
        stackView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16).isActive = true
        stackView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -16).isActive = true
    }
}
