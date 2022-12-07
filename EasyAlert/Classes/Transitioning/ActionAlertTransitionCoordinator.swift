//
//  ActionAlertTransitionCoordinator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

struct ActionAlertTransitionCoordinator : TransitionCoordinator {
    
    private var coordinator: TransitionCoordinator
    private weak var actionGroupView: ActionGroupView?
    
    var duration: TimeInterval {
        get { coordinator.duration }
        set { coordinator.duration = newValue }
    }
    
    var size: Size {
        get { coordinator.size }
        set { coordinator.size = newValue }
    }
    
    init(coordinator: TransitionCoordinator, actionGroupView: ActionGroupView) {
        self.coordinator = coordinator
        self.actionGroupView = actionGroupView
    }
    
    func update(context: TransitionCoordinatorContext) {
        coordinator.update(context: context)
        actionGroupView?.updateLayout(interfaceOrientation: context.interfaceOrientation, width: size.width)
    }
    
    func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        coordinator.show(context: context, completion: completion)
    }
    
    func dismiss(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        coordinator.dismiss(context: context, completion: completion)
    }
}
