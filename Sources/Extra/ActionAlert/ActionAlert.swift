//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by iya on 2021/7/28.
//

import UIKit

open class ActionAlert: Alert, _ActionAlertable {
    
    var actions: [Action] { actionGroupView.actions }
    
    private let actionGroupView: ActionGroupView
    
    private let configuration: ActionAlertableConfigurable
    
    public required init(
        content: AlertCustomizable,
        configuration: ActionAlertableConfigurable? = nil
    ) {
        self.configuration = configuration ?? ActionAlert.Configuration.global
        let actionLayout = self.configuration.actionLayoutType.init()
        actionGroupView = ActionGroupView(content: content, actionLayout: actionLayout)
        super.init(content: actionGroupView)
        addListener(actionGroupView)
        
        layoutGuide = self.configuration.layoutGuide
        
        let decorator = ActionGroupAnimatorAndLayoutDecorator(
            aniamtor: AlertTransitionAnimator(),
            layoutModifier: AlertLayoutModifier(),
            actionGroupViews: [actionGroupView]
        )
        self.transitionAniamtor = decorator
        self.layoutModifier = decorator
    }
    
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        actionGroupView.setCornerRadius(configuration.cornerRadius)
    }
}

extension ActionAlert {
    
    public func setPresentationBackground(view: UIView) {
        actionGroupView.backgroundView = view
    }
    
    public func setPresentationBackground(color: UIColor) {
        let view = UIView()
        view.backgroundColor = color
        setPresentationBackground(view: view)
    }
}

extension ActionAlert {
    
    public func addAction(_ action: Action) {
        guard canAddAction(action) else { return }
        
        actionGroupView.actions.append(action)
        setViewForAction(action)
        
        if let index = cancelActionIndex {
            let cancelAction = actionGroupView.actions.remove(at: index)
            // action 数量为 1 时，将 cancelAction 放置在第一个，否则放在最后一个。
            if actionGroupView.actions.count == 1 {
                actionGroupView.actions.insert(cancelAction, at: 0)
            } else {
                actionGroupView.actions.append(cancelAction)
            }
        }
    }
    
    private func setViewForAction(_ action: Action) {
        if action.view == nil {
            action.view = configuration.actionViewType.init(style: action.style)
            action.view?.title = action.title
        }
    }
}
