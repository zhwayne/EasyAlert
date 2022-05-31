//
//  ActionAlertLayout.swift
//  EasyAlert
//
//  Created by iya on 2021/12/21.
//

import Foundation

class ActionAlertLayout: AlertLayout {
    
    weak var alertCustomView: ActionAlert.ContentView?
    
    override func layout(content: Alert.CustomizedView, container: UIView, interfaceOrientation: UIInterfaceOrientation) {
        super.layout(content: content, container: container, interfaceOrientation: interfaceOrientation)
        alertCustomView?.updateLayout(interfaceOrientation: interfaceOrientation, width: width)
    }
}
