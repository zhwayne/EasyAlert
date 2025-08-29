//
//  TransitionAnimatorActionGroupDecorator.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import Foundation

final class ActionGroupAnimatorAndLayoutDecorator: AlertbleAnimator, AlertableLayout {
    
    private var aniamtor: AlertbleAnimator
    private var layoutModifier: AlertableLayout
    private var actionGroupViews: [ActionGroupView] = []
    
    init(aniamtor: AlertbleAnimator, layoutModifier: AlertableLayout, actionGroupViews: [ActionGroupView]) {
        self.aniamtor = aniamtor
        self.layoutModifier = layoutModifier
        self.actionGroupViews = actionGroupViews
    }
    
    func updateLayout(context: LayoutContext, layoutGuide: LayoutGuide) {
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
