//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/28.
//

import UIKit

open class ActionAlert: Alert, _ActionAlertble {
    
    var actions: [Action] { actionGroupView.actions }

    public static var globalConfiguration = Configuration()
    
    private let actionGroupView: ActionGroupView
    
    private let configuration: ActionAlertbleConfigurable
    
    public required init<T: AlertCustomizable>(
        customizable: T,
        configuration: ActionAlertbleConfigurable? = nil
    ) {
        self.configuration = configuration ?? ActionAlert.Configuration.global
        let actionLayout = self.configuration.actionLayoutType.init()
        if let view = customizable as? UIView {
            actionGroupView = ActionGroupView(customView: view,
                                              actionLayout: actionLayout)
        } else if let viewController = customizable as? UIViewController {
            actionGroupView = ActionGroupView(customView: viewController.view,
                                              actionLayout: actionLayout)
        } else {
            fatalError()
        }
        super.init(customizable: actionGroupView)
        
        let decorator = TransitionCoordinatorActionGroupDecorator(
            coordinator: AlertTransitionCoordinator(),
            actionGroupViews: [actionGroupView]
        )
        self.transitionCoordinator = decorator
    }
    
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        actionGroupView.setCornerRadius(configuration.cornerRadius)
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
