//
//  Sheet.swift
//  EasyAlert
//
//  Created by iya on 2021/12/13.
//

import UIKit

open class Sheet: Alert {

    public override init(content: AlertContent) {
        super.init(content: content)
        self.animator = SheetAnimator()
        self.layout = SheetLayout()
        layoutGuide = .init(width: .multiplied(by: 1, maxWidth: 414), height: .flexible)
    }
}
