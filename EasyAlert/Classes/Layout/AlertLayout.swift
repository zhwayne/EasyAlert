//
//  AlertLayout.swift
//  EasyAlert
//
//  Created by iya on 2021/12/13.
//

import Foundation
import SnapKit

class AlertLayout: AlertLayoutable {
    
    var width: Alert.Width = .fixed(270)
    
    var height: Alert.Height = .automic
    
    func layout(with context: AlertLayoutContext) {

        context.container.snp.remakeConstraints { maker in
            switch width {
            case let .fixed(value): maker.width.equalTo(value)
            case let .flexible(value): maker.width.lessThanOrEqualTo(value)
            case let .multiplied(value):
                if context.interfaceOrientation.isPortrait {
                    maker.width.equalToSuperview().multipliedBy(value)
                } else {
                    maker.width.equalTo(context.container.superview!.snp.height).multipliedBy(value)
                }
            }
            if case let .greaterThanOrEqualTo(value) = height {
                maker.height.greaterThanOrEqualTo(value)
            }

            maker.center.equalToSuperview()
        }
    }
}

extension CGRect {
    
    public init(center: CGPoint, size: CGSize) {
        self.init()
        self.size = size
        self.origin = CGPoint(x: center.x - size.width / 2,
                              y: center.y - size.height / 2)
    }
}
