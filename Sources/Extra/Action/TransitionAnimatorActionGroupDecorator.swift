//
//  TransitionAnimatorActionGroupDecorator.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import Foundation

final class ActionGroupAnimatorAndLayoutDecorator: TransitionAnimator, AlertableLayout {
    
    private var aniamtor: TransitionAnimator
    private var layoutModifier: AlertableLayout
    private var actionGroupViews: [ActionGroupView] = []
    
    init(aniamtor: TransitionAnimator, layoutModifier: AlertableLayout, actionGroupViews: [ActionGroupView]) {
        self.aniamtor = aniamtor
        self.layoutModifier = layoutModifier
        self.actionGroupViews = actionGroupViews
    }
    
    func update(context: LayoutContext, layoutGuide: LayoutGuide) {
        layoutModifier.update(context: context, layoutGuide: layoutGuide)
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
