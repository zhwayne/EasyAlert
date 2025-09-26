//
//  AlertWindow.swift
//  EasyAlert
//
//  Created by iya on 2022/12/23.
//

import UIKit

internal class AlertWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view === self || view === rootViewController?.view { return nil }
        return view
    }
}
