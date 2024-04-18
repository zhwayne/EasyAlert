//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by iya on 2021/7/28.
//

import UIKit

open class ActionAlert: Alert, _ActionAlertble {
    
    class ContainerView: UIView, AlertCustomizable { }
    
    var actions: [Action] { actionGroupView.actions }
    
    private let containerView = ContainerView()
    private let actionGroupView: ActionGroupView
    private let configuration: ActionAlertConfigurable
    
    public required init(
        customizable: AlertCustomizable,
        configuration: ActionAlertConfigurable? = nil
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
            fatalError("Unsupported type: \(type(of: customizable))")
        }
        
        if let type = self.configuration.backgroundViewType {
            actionGroupView.backgroundView = type.init()
        } else {
            if #available(iOS 13.0, *) {
                actionGroupView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            } else {
                // Fallback on earlier versions
                actionGroupView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
            }
        }
        
        containerView.addSubview(actionGroupView)
        actionGroupView.frame = containerView.bounds
        actionGroupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        super.init(customizable: containerView)
        
        layoutGuide = self.configuration.layoutGuide
        
        let decorator = TransitionAnimatorActionGroupDecorator(
            aniamtor: AlertTransitionAnimator(),
            actionGroupViews: [actionGroupView]
        )
        self.transitionAniamtor = decorator
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
