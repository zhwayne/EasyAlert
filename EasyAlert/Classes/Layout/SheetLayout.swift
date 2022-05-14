//
//  SheetLayout.swift
//  EasyAlert
//
//  Created by iya on 2021/12/13.
//

import Foundation

class SheetLayout: AlertLayoutable {
    
    var width: Alert.Width = .multiplied(1)
    
    func layout(content: Alert.CustomizedView, container: UIView, interfaceOrientation: UIInterfaceOrientation) {
        container.addSubview(content)
        
        content.snp.remakeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints { maker in
            switch width {
            case let .fixed(value): maker.width.equalTo(value)
            case let .flexible(value): maker.width.lessThanOrEqualTo(value)
            case let .multiplied(value):
                if interfaceOrientation.isPortrait {
                    maker.width.equalToSuperview().multipliedBy(value)
                } else {
                    maker.width.equalTo(container.superview!.snp.height).multipliedBy(value).priority(.high)
                }
            }
            maker.centerX.equalToSuperview()
            maker.height.greaterThanOrEqualTo(44)
            maker.bottom.equalToSuperview()
        }
    }
}
