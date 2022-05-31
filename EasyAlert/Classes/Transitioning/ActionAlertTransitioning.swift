//
//  ActionAlertTransitioning.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

final class ActionAlertTransitioning : AlertTransitioning {
    
    weak var alertCustomView: ActionAlert.ContentView?
    
    override func update(context: TransitioningContext) {
        super.update(context: context)
        alertCustomView?.updateLayout(interfaceOrientation: context.interfaceOrientation, width: layoutSize.width)
    }
}
