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
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))
        }
    }
}
