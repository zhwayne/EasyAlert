//
//  TransitionAnimatorActionGroupDecorator.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import Foundation

struct TransitionAnimatorActionGroupDecorator: TransitionAnimator {
    
    private var aniamtor: TransitionAnimator
    private var actionGroupViews: [ActionGroupView] = []
    
    init(aniamtor: TransitionAnimator, actionGroupViews: [ActionGroupView]) {
        self.aniamtor = aniamtor
        self.actionGroupViews = actionGroupViews
    }
    
    mutating func update(context: TransitionContext, layoutGuide: LayoutGuide) {
        aniamtor.update(context: context, layoutGuide: layoutGuide)
        actionGroupViews.forEach { view in
            view.updateLayout(interfaceOrientation: context.interfaceOrientation)
        }
    }
    
    mutating func show(context: TransitionContext, completion: @escaping () -> Void) {
        aniamtor.show(context: context, completion: completion)
    }
    
    mutating func dismiss(context: TransitionContext, completion: @escaping () -> Void) {
        aniamtor.dismiss(context: context, completion: completion)
    }
}
