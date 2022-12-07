//
//  TransitionCoordinatorActionGroupDecorator.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import Foundation

struct TransitionCoordinatorActionGroupDecorator: TransitionCoordinator {
    
    private var coordinator: TransitionCoordinator
    private weak var actionGroupView: ActionGroupView?
    
    var duration: TimeInterval {
        get { coordinator.duration }
        set { coordinator.duration = newValue }
    }
    
    var layoutGuide: LayoutGuide {
        get { coordinator.layoutGuide }
        set { coordinator.layoutGuide = newValue }
    }
    
    init(coordinator: TransitionCoordinator, actionGroupView: ActionGroupView) {
        self.coordinator = coordinator
        self.actionGroupView = actionGroupView
    }
    
    func update(context: TransitionCoordinatorContext) {
        coordinator.update(context: context)
        actionGroupView?.updateLayout(interfaceOrientation: context.interfaceOrientation, width: layoutGuide.width)
    }
    
    func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        coordinator.show(context: context, completion: completion)
    }
    
    func dismiss(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        coordinator.dismiss(context: context, completion: completion)
    }
}
