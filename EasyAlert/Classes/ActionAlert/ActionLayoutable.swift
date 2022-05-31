//
//  ActionLayoutable.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import Foundation
import SnapKit

public protocol ActionLayoutable {
    
    func layout(actionViews: [UIView], container: UIView)
}

public extension ActionLayoutable {
    
    func layout(actionViews: [UIView], container: UIView) {
        
        let stackView = UIStackView(arrangedSubviews: actionViews)
        stackView.axis = actionViews.count <= 2 ? .horizontal : .vertical
        stackView.distribution = .fillEqually
        container.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if actionViews.count == 2 {
            let horizontalSeparator = makeSeparator()
            container.addSubview(horizontalSeparator)
            horizontalSeparator.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(1 / UIScreen.main.scale)
            }
            
            let verticalSeparator = makeSeparator()
            container.addSubview(verticalSeparator)
            verticalSeparator.snp.makeConstraints { make in
                make.top.bottom.centerX.equalToSuperview()
                make.width.equalTo(1 / UIScreen.main.scale)
            }
        } else {
            actionViews.forEach { button in
                let horizontalSeparator = makeSeparator()
                container.addSubview(horizontalSeparator)
                horizontalSeparator.snp.makeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(button)
                    make.height.equalTo(1 / UIScreen.main.scale)
                }
            }
        }
    }
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        if #available(iOS 13.0, *) {
            separator.backgroundColor = UIColor.tertiaryLabel
        } else {
            separator.backgroundColor = UIColor(white: 0.237, alpha: 0.29)
        }
        return separator
    }
}

extension ActionAlert {
    
    struct ActionLayout: ActionLayoutable { }
}
