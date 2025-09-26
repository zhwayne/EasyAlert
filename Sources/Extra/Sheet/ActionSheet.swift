//
//  ActionSheet.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import UIKit

/// An action sheet that displays a list of actions from which the user can choose.
///
/// `ActionSheet` extends the base `Sheet` class to provide action button functionality.
/// It typically appears as a modal sheet from the bottom of the screen with a list of actions.
open class ActionSheet: Sheet, ActionAlertable {

    /// The array of all actions available in this action sheet.
    ///
    /// This includes both regular actions and cancel actions.
    public var actions: [Action] { actionGroupView.actions + cancelActionGroupView.actions }

    /// The container view that holds all action group views.
    private let containerView = ActionSheet.ContainerView()

    /// The view that manages the group of regular action buttons.
    private let actionGroupView: ActionGroupView

    /// The view that manages the group of cancel action buttons.
    private var cancelActionGroupView: ActionGroupView

    /// The configuration object that defines the action sheet's appearance and behavior.
    private let configuration: ActionAlertableConfigurable

    /// Creates an action sheet with the specified content and configuration.
    ///
    /// - Parameters:
    ///   - content: An optional content to display in the action sheet.
    ///   - configuration: An optional configuration object. If `nil`, the global configuration is used.
    public init(
        content: AlertContent? = nil,
        configuration: ActionAlertableConfigurable? = nil
    ) {
        self.configuration = configuration ?? ActionSheet.Configuration.global
        let actionLayout = self.configuration.makeActionLayout()
        let cancelActionLayout = self.configuration.makeActionLayout()

        if content is UIView || content is UIViewController {
            actionGroupView = ActionGroupView(content: content, actionLayout: actionLayout)
        } else {
            actionGroupView = ActionGroupView(content: nil, actionLayout: actionLayout)
        }

        cancelActionGroupView = ActionGroupView(content: nil, actionLayout: cancelActionLayout)
        super.init(content: containerView)
        addListener(actionGroupView)

        layoutGuide = self.configuration.layoutGuide

        let decorator = ActionGroupAnimatorAndLayoutDecorator(
            aniamtor: animator,
            layoutModifier: layout,
            actionGroupViews: [actionGroupView, cancelActionGroupView]
        )
        animator = decorator
        layout = decorator
        backdrop.allowDismissWhenBackgroundTouch = true
    }

    /// Called before the action sheet container is laid out.
    ///
    /// This method configures the action group container and applies corner radius styling.
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        configureActionGroupContainer()
        if let cancelSpacing = configuration.value(for: "cancelSpacing") as? CGFloat,
           cancelSpacing > 1 {
            actionGroupView.setCornerRadius(configuration.cornerRadius)
            cancelActionGroupView.setCornerRadius(configuration.cornerRadius)
        }
        containerView.layer.cornerCurve = .continuous
        containerView.layer.cornerRadius = configuration.cornerRadius
        containerView.layer.masksToBounds = true
    }
}

extension ActionSheet {

    /// Sets a custom background view for the specified domain in the action sheet.
    ///
    /// - Parameters:
    ///   - view: The custom view to use as the background.
    ///   - domain: The domain (normal or cancel) to apply the background to.
    public func setPresentationBackground(view: UIView, for domain: PresentationBackgroundDomain) {
        switch domain {
        case .normal:
            actionGroupView.backgroundView = view
        case .cancel:
            cancelActionGroupView.backgroundView = view
        }
    }

    /// Sets a solid color background for the specified domain in the action sheet.
    ///
    /// - Parameters:
    ///   - color: The color to use for the background.
    ///   - domain: The domain (normal or cancel) to apply the background to.
    public func setPresentationBackground(color: UIColor, for domain: PresentationBackgroundDomain) {
        let view = UIView()
        view.backgroundColor = color
        setPresentationBackground(view: view, for: domain)
    }
}

extension ActionSheet {

    private func configureActionGroupContainer() {
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
            action.view = configuration.makeActionView(action.style)
            action.view?.title = action.title
        }
    }
}

public final class EmptyContentView: UIView, AlertContent { }
