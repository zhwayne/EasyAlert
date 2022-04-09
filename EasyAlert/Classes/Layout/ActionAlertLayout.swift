//
//  ActionAlertLayout.swift
//  EasyAlert
//
//  Created by iya on 2021/12/21.
//

import Foundation

class ActionAlertLayout: AlertLayout {
    
    weak var alertCustomView: ActionAlert.ActionAlertCustomView?
    
    override func updateLayout(container: UIView, content: UIView, interfaceOrientation: UIInterfaceOrientation) {
        super.updateLayout(container: container, content: content, interfaceOrientation: interfaceOrientation)
        alertCustomView?.updateLayout(interfaceOrientation: interfaceOrientation, width: width)
    }
}
