//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/28.
//

import UIKit

open class ActionAlert: Alert {
    
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
        let transitionCoordinator = ActionAlertTransitionCoordinator()
        transitionCoordinator.alertCustomView = actionGroupView
        self.transitionCoordinator = transitionCoordinator
    }
    
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        actionGroupView.setCornerRadius(configuration.cornerRadius)
    }
}

extension ActionAlert: ActionAlertble {
    
    public func addAction(_ action: Action) {
        assert(isShowing == false)
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
