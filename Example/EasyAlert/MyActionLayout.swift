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

    func layout(buttons: [UIView], container: UIView) {

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = buttons.count <= 3 ? .horizontal : .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 20
        container.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
        }
    }
}
