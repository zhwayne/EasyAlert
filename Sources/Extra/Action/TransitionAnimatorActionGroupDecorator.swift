//
//  TransitionAnimatorActionGroupDecorator.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import Foundation

final class ActionGroupAnimatorAndLayoutDecorator: AlertTransitionAnimatable, AlertLayoutUpdatable {
    
    private var aniamtor: AlertTransitionAnimatable
    private var layoutModifier: AlertLayoutUpdatable
    private var actionGroupViews: [ActionGroupView] = []
    
    init(aniamtor: AlertTransitionAnimatable, layoutModifier: AlertLayoutUpdatable, actionGroupViews: [ActionGroupView]) {
        self.aniamtor = aniamtor
        self.layoutModifier = layoutModifier
        self.actionGroupViews = actionGroupViews
    }
    
    func updateLayout(context: LayoutContext, layoutGuide: AlertLayoutGuide) {
        layoutModifier.updateLayout(context: context, layoutGuide: layoutGuide)
        actionGroupViews.forEach { view in
            view.updateLayout(interfaceOrientation: context.interfaceOrientation)
        }
    }
    
    func show(context: LayoutContext, completion: @escaping () -> Void) {
        aniamtor.show(context: context, completion: completion)
    }
    
    func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        aniamtor.dismiss(context: context, completion: completion)
    }
}
