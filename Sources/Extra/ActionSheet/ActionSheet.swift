//
//  ActionSheet.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import UIKit

open class ActionSheet: Sheet, _ActionAlertble {
    
    class ContainerView: UIView, AlertCustomizable { }
    
    var actions: [Action] { actionGroupView.actions + cancelActionGroupView.actions }
    
    private let containerView = ContainerView()
    
    private let actionGroupView: ActionGroupView
    
    private var cancelActionGroupView: ActionGroupView
    
    private let configuration: ActionSheetConfigurable
    
    public init(
        customizable: AlertCustomizable? = nil,
        configuration: ActionSheetConfigurable? = nil
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
            actionGroupView = ActionGroupView(customView: nil,
                                              actionLayout: actionLayout)
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

        cancelActionGroupView = ActionGroupView(customView: nil, actionLayout: cancelActionLayout)
        super.init(customizable: containerView)
        
        layoutGuide = self.configuration.layoutGuide
        let decorator = TransitionAnimatorActionGroupDecorator(
            aniamtor: transitionAniamtor,
            actionGroupViews: [actionGroupView, cancelActionGroupView]
        )
        transitionAniamtor = decorator
    }
    
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        configActionGroupContainer()
        if let cancelSpacing = configuration.value(for: "cancelSpacing") as? CGFloat,
           cancelSpacing > 1 {
            actionGroupView.setCornerRadius(configuration.cornerRadius)
            cancelActionGroupView.setCornerRadius(configuration.cornerRadius)
        }
        if #available(iOS 13.0, *) {
            containerView.layer.cornerCurve = .continuous
        }
        containerView.layer.cornerRadius = configuration.cornerRadius
        containerView.layer.masksToBounds = true
    }
}

extension ActionSheet {
    
    public func setPresentationBackground(view: UIView, for domain: PresentationBackgroundDomain) {
        switch domain {
        case .normal:
            actionGroupView.backgroundView = view
        case .cancel:
            cancelActionGroupView.backgroundView = view
        }
    }
    
    public func setPresentationBackground(color: UIColor, for domain: PresentationBackgroundDomain) {
        let view = UIView()
        view.backgroundColor = color
        setPresentationBackground(view: view, for: domain)
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
        
        if let cancelSpacing = configuration.value(for: "cancelSpacing") as? CGFloat,
           cancelSpacing > 1, cancelActionGroupView.superview != containerView {
            containerView.addSubview(cancelActionGroupView)
            cancelActionGroupView.translatesAutoresizingMaskIntoConstraints = false
            
            cancelActionGroupView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            cancelActionGroupView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            cancelActionGroupView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            let constraint = cancelActionGroupView.topAnchor.constraint(equalTo: actionGroupView.bottomAnchor, constant: cancelSpacing)
            constraint.isActive = true
        }
    }
}

extension ActionSheet {
    
    public func addAction(_ action: Action) {
        guard canAddAction(action) else { return }
        
        if let cancelSpacing = configuration.value(for: "cancelSpacing") as? CGFloat,
            cancelSpacing > 1 {
            // cancelAction 放置在  `cancelActionGroupView.actions` 中，其他类型的 action 放置在
            // `actionGroupView.actions` 中。`cancelActionGroupView.actions` 的数量为 0 或者 1。
            if action.style != .cancel {
                actionGroupView.actions.append(action)
            } else {
                cancelActionGroupView.actions.append(action)
            }
            setViewForAction(action)
        } else {
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
    }
    
    private func setViewForAction(_ action: Action) {
        if action.view == nil {
            action.view = configuration.actionViewType.init(style: action.style)
            action.view?.title = action.title
        }
    }
}

public final class EmptyContentView: UIView { }
