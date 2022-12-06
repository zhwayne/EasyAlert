//
//  ActionAlertTransitionCoordinator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

final class ActionAlertTransitionCoordinator : AlertTransitionCoordinator {
    
    weak var alertCustomView: ActionGroupView?
    
    override func update(context: TransitionCoordinatorContext) {
        super.update(context: context)
        alertCustomView?.updateLayout(interfaceOrientation: context.interfaceOrientation, width: size.width)
    }
}
