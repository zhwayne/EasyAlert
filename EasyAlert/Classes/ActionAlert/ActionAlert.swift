//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/28.
//

import UIKit

open class ActionAlert: Alert, ActionAddable {
    
    var actions: [Action] { actionGroupView.actions }

    public static var globalConfiguration = Configuration()
    
    private let actionGroupView: ActionGroupView
    
    private let configuration: ActionAlertbleConfigurable
    
    public required init(
        customView: CustomizedView,
        configuration: ActionAlertbleConfigurable? = nil
    ) {
        self.configuration = configuration ?? ActionAlert.Configuration.global
        actionGroupView = ActionGroupView(customView: customView,
                                           actionLayout: self.configuration.actionLayout)
        super.init(customView: actionGroupView)
        
        let decorator = TransitionCoordinatorActionGroupDecorator(
            coordinator: AlertTransitionCoordinator(),
            actionGroupView: actionGroupView
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
    }
    
    private func setViewForAction(_ action: Action) {
        if action.view == nil {
            action.view = configuration.actionViewType.init(style: action.style)
            action.view?.title = action.title
        }
    }
}
