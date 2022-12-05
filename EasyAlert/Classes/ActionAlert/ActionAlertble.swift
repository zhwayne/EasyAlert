//
//  ActionAlertble.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/4.
//

import Foundation

public protocol ActionAlertble: Alertble {
    
    func addAction(_ action: Action)
}

public extension ActionAlertble {
    
    func addActions(_ actions: [Action]) {
        actions.forEach { addAction($0) }
    }
}
