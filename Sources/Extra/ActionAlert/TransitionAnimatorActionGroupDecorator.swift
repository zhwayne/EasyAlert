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
    
    mutating func update(with context: TransitionContext) {
        aniamtor.update(with: context)
        actionGroupViews.forEach { view in
            view.updateLayout(interfaceOrientation: context.interfaceOrientation)
        }
    }
    
    mutating func show(with context: TransitionContext, completion: @escaping () -> Void) {
        aniamtor.show(with: context, completion: completion)
    }
    
    mutating func dismiss(with context: TransitionContext, completion: @escaping () -> Void) {
        aniamtor.dismiss(with: context, completion: completion)
    }
}
