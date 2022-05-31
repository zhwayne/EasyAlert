//
//  ActionAlertLayout.swift
//  EasyAlert
//
//  Created by iya on 2021/12/21.
//

import Foundation

class ActionAlertLayout: AlertLayout {
    
    weak var alertCustomView: ActionAlert.ContentView?
    
    override func layout(with context: AlertLayoutContext) {
        super.layout(with: context)
        alertCustomView?.updateLayout(interfaceOrientation: context.interfaceOrientation, width: width)
    }
}
