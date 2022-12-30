//
//  TransitionCoordinatorActionGroupDecorator.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import Foundation

struct TransitionCoordinatorActionGroupDecorator: TransitionCoordinator {
    
    private var coordinator: TransitionCoordinator
    private var actionGroupViews: [ActionGroupView] = []
    
    var layoutGuide: LayoutGuide {
        get { coordinator.layoutGuide }
        set { coordinator.layoutGuide = newValue }
    }
    
    init(coordinator: TransitionCoordinator, actionGroupViews: [ActionGroupView]) {
        self.coordinator = coordinator
        self.actionGroupViews = actionGroupViews
    }
    
    mutating func update(context: TransitionCoordinatorContext) {
        coordinator.update(context: context)
        actionGroupViews.forEach { view in
            view.updateLayout(interfaceOrientation: context.interfaceOrientation, width: layoutGuide.width)
        }
    }
    
    mutating func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        coordinator.show(context: context, completion: completion)
    }
    
    mutating func dismiss(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        coordinator.dismiss(context: context, completion: completion)
    }
}
