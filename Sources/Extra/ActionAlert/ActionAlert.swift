//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by iya on 2021/7/28.
//

import UIKit

open class ActionAlert: Alert, _ActionAlertble {
    
    var actions: [Action] { actionGroupView.actions }
    
    private let actionGroupView: ActionGroupView
    
    private let configuration: ActionAlertbleConfigurable
    
    public required init(
        content: AlertCustomizable,
        configuration: ActionAlertbleConfigurable? = nil
    ) {
        self.configuration = configuration ?? ActionAlert.Configuration.global
        let actionLayout = self.configuration.actionLayoutType.init()
        if let view = content as? UIView {
            actionGroupView = ActionGroupView(customView: view,
                                              actionLayout: actionLayout)
        } else if let viewController = content as? UIViewController {
            actionGroupView = ActionGroupView(customView: viewController.view,
                                              actionLayout: actionLayout)
        } else {
            fatalError("Unsupported type: \(type(of: content))")
        }
        super.init(content: actionGroupView)
        
        layoutGuide.contentInsets = self.configuration.contentInsets
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
