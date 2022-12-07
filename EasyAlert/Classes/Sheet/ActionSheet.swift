//
//  ActionSheet.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import Foundation

open class ActionSheet: Sheet, ActionAddable {
    
    var actions: [Action] {
        if let cancelActions = cancelActionGroupView?.actions {
            return actionGroupView.actions + cancelActions
        }
        return actionGroupView.actions
    }
    
    private let containerView = ActionSheet.ContainerView()
    
    private let actionGroupView: ActionGroupView
    
    private var cancelActionGroupView: ActionGroupView?
    
    private let configuration: ActionAlertbleConfigurable
    
    public required init(
        customView: CustomizedView,
        configuration: ActionAlertbleConfigurable? = nil
    ) {
        self.configuration = configuration ?? ActionSheet.Configuration.global
        let actionLayout = self.configuration.actionLayoutType.init()
        actionGroupView = ActionGroupView(customView: customView,
                                          actionLayout: actionLayout)
        super.init(customView: containerView)
        
        var coordinator = SheetTransitionCoordinator()
        coordinator.layoutGuide.edgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: -8)
        coordinator.layoutGuide.ignoreBottomSafeArea = false
        let decorator = TransitionCoordinatorActionGroupDecorator(
            coordinator: coordinator,
            actionGroupView: actionGroupView
        )
        self.transitionCoordinator = decorator
    }
    
    open override func willLayoutContainer() {
        configActionGroupContainer()
        super.willLayoutContainer()
        actionGroupView.setCornerRadius(configuration.cornerRadius)
    }
    
}

extension ActionSheet {
    
    private func configActionGroupContainer() {
        if actionGroupView.superview != containerView {
            containerView.addSubview(actionGroupView)
            actionGroupView.translatesAutoresizingMaskIntoConstraints = false
            
            actionGroupView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            actionGroupView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            actionGroupView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            let constraint = actionGroupView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            constraint.priority = .defaultHigh - 1
            constraint.isActive = true
        }
        
//        if actions.count > 1 && cancelActionGroupView == nil {
//            cancelActionGroupView = ActionGroupView(customView: nil,
//                                                    actionLayoutType: self.configuration.actionLayoutType)
//            actionGroupContainerView.addSubview(cancelActionGroupView!)
//            actionGroupView!.translatesAutoresizingMaskIntoConstraints = false
//
//            actionGroupView.leftAnchor.constraint(
//                equalTo: actionGroupContainerView.safeAreaLayoutGuide.leftAnchor,
//                constant: self.configuration.edgeInsets.left
//            ).isActive = true
//            actionGroupView.rightAnchor.constraint(
//                equalTo: actionGroupContainerView.safeAreaLayoutGuide.rightAnchor,
//                constant: -self.configuration.edgeInsets.right
//            ).isActive = true
//            actionGroupView.topAnchor.constraint(
//                equalTo: actionGroupView.bottomAnchor.topAnchor,
//                constant: self.configuration.edgeInsets.top
//            ).isActive = true
//            actionGroupView.bottomAnchor.constraint(
//                equalTo: actionGroupContainerView.safeAreaLayoutGuide.bottomAnchor,
//                constant: -self.configuration.edgeInsets.bottom
//            ).isActive = true
//        }
    }
}

extension ActionSheet {
    
    public func addAction(_ action: Action) {
        guard canAddAction(action) else { return }
        
        // cancelAction 放置在  `cancelActionGroupView.actions` 中，其他类型的 action 放置在
        // `actionGroupView.actions` 中。`cancelActionGroupView.actions` 的数量为 0 或者 1。
        if action.style != .cancel {
            actionGroupView.actions.append(action)
        } else {
            cancelActionGroupView?.actions.append(action)
        }
        setViewForAction(action)
    }
    
    private func setViewForAction(_ action: Action) {
        if action.view == nil {
            if configuration.actionViewType == ActionView.self {
                action.view = ActionView(style: action.style, alertbleStyle: .sheet)
            } else {
                action.view = configuration.actionViewType.init(style: action.style)
            }
            action.view?.title = action.title
        }
    }
}
