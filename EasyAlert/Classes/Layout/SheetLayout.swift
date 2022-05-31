//
//  SheetLayout.swift
//  EasyAlert
//
//  Created by iya on 2021/12/13.
//

import Foundation

class SheetLayout: AlertLayoutable {
    
    var width: Alert.Width = .multiplied(1)
    
    var height: Alert.Height = .greaterThanOrEqualTo(44)
    
    func layout(with context: AlertLayoutContext) {
        
        context.container.snp.remakeConstraints { maker in
            switch width {
            case let .fixed(value): maker.width.equalTo(value)
            case let .flexible(value): maker.width.lessThanOrEqualTo(value)
            case let .multiplied(value):
                if context.interfaceOrientation.isPortrait {
                    maker.width.equalToSuperview().multipliedBy(value)
                } else {
                    maker.width.equalTo(context.container.superview!.snp.height).multipliedBy(value).priority(.high)
                }
            }
            if case let .greaterThanOrEqualTo(value) = height {
                maker.height.greaterThanOrEqualTo(value)
            }
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
}
