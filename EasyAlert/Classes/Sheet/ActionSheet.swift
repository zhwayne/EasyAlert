//
//  ActionSheet.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import Foundation

open class ActionSheet: Sheet {
    
    private let actionGroupView: ActionGroupView
    
    private var cancelActionGroupView: ActionGroupView?
    
    private let configuration: ActionAlertbleConfigurable
    
    public required init(
        customView: CustomizedView,
        configuration: ActionAlertbleConfigurable? = nil
    ) {
        self.configuration = configuration ?? ActionSheet.Configuration.global
        actionGroupView = ActionGroupView(customView: customView,
                                          actionLayout: self.configuration.actionLayout)
        let containerView = ActionSheet.ContainerView()
        containerView.addSubview(actionGroupView)
        actionGroupView.translatesAutoresizingMaskIntoConstraints = false
        actionGroupView.leftAnchor.constraint(
            equalTo: containerView.safeAreaLayoutGuide.leftAnchor,
            constant: self.configuration.edgeInsets.left
        ).isActive = true
        actionGroupView.rightAnchor.constraint(
            equalTo: containerView.safeAreaLayoutGuide.rightAnchor,
            constant: -self.configuration.edgeInsets.right
        ).isActive = true
        actionGroupView.topAnchor.constraint(
            equalTo: containerView.safeAreaLayoutGuide.topAnchor,
            constant: self.configuration.edgeInsets.top
        ).isActive = true
        actionGroupView.bottomAnchor.constraint(
            equalTo: containerView.safeAreaLayoutGuide.bottomAnchor,
            constant: -self.configuration.edgeInsets.bottom
        ).isActive = true

        super.init(customView: containerView)
        
        let decorator = TransitionCoordinatorActionGroupDecorator(
            coordinator: SheetTransitionCoordinator(),
            actionGroupView: actionGroupView
        )
        self.transitionCoordinator = decorator
    }
    
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        actionGroupView.setCornerRadius(configuration.cornerRadius)
    }
}

extension ActionSheet: ActionAlertble {
    
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
