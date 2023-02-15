//
//  ActionSheet.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import Foundation

open class ActionSheet: Sheet, _ActionAlertble {
    
    var actions: [Action] { actionGroupView.actions + cancelActionGroupView.actions }
    
    private let containerView = ActionSheet.ContainerView()
    
    private let actionGroupView: ActionGroupView
    
    private var cancelActionGroupView: ActionGroupView
    
    private let configuration: ActionAlertbleConfigurable
    
    public required init<T: AlertCustomizable>(
        customizable: T,
        configuration: ActionAlertbleConfigurable? = nil
    ) {
        self.configuration = configuration ?? ActionSheet.Configuration.global
        let actionLayout = self.configuration.actionLayoutType.init()
        let cancelActionLayout = self.configuration.actionLayoutType.init()
        
        if let view = customizable as? UIView {
            actionGroupView = ActionGroupView(customView: view,
                                              actionLayout: actionLayout)
        } else if let viewController = customizable as? UIViewController {
            actionGroupView = ActionGroupView(customView: viewController.view,
                                              actionLayout: actionLayout)
        } else {
            fatalError()
        }

        cancelActionGroupView = ActionGroupView(customView: nil, actionLayout: cancelActionLayout)
        super.init(customizable: containerView)
        
        ignoreBottomSafeArea = false
        
        layoutGuide.edgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        let decorator = TransitionAnimatorActionGroupDecorator(
            aniamtor: transitionAniamtor,
            actionGroupViews: [actionGroupView, cancelActionGroupView]
        )
        transitionAniamtor = decorator
    }
    
    open override func willLayoutContainer() {
        configActionGroupContainer()
        super.willLayoutContainer()
        actionGroupView.setCornerRadius(configuration.cornerRadius)
        cancelActionGroupView.setCornerRadius(configuration.cornerRadius)
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
        
        if cancelActionGroupView.superview != containerView {
            containerView.addSubview(cancelActionGroupView)
            cancelActionGroupView.translatesAutoresizingMaskIntoConstraints = false
            
            cancelActionGroupView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            cancelActionGroupView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            cancelActionGroupView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            
            var offset: CGFloat = 0
            let mirror = Mirror(reflecting: self.configuration)
            for child in mirror.children {
                if child.label == "cancelSpacing" {
                    offset = child.value as! CGFloat
                    break
                }
            }
            let constraint = cancelActionGroupView.topAnchor.constraint(equalTo: actionGroupView.bottomAnchor, constant: offset)
            constraint.isActive = true
        }
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
            cancelActionGroupView.actions.append(action)
        }
        setViewForAction(action)
    }
    
    private func setViewForAction(_ action: Action) {
        if action.view == nil {
            action.view = configuration.actionViewType.init(style: action.style)
            action.view?.title = action.title
        }
    }
}
