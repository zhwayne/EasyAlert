//
//  AlertWindow.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/23.
//

import UIKit

class AlertWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self { return nil }
        return view
    }
}
