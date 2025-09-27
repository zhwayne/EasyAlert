//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by iya on 2021/7/28.
//

import UIKit

/// An alert that displays a message with action buttons.
///
/// `ActionAlert` extends the base `Alert` class to provide action button functionality.
/// It allows you to add multiple actions that users can tap to respond to the alert.
/// The alert supports various action styles including default, cancel, and destructive actions.
open class ActionAlert: Alert, ActionAlertable {

    /// The array of actions available in this alert.
    ///
    /// This property provides access to all actions that have been added to the alert.
    public var actions: [Action] { actionGroupView.actions }

    /// The view that manages the group of action buttons.
    ///
    /// This view is responsible for displaying and laying out all the action buttons
    /// within the alert, including proper spacing and visual separators.
    private let actionGroupView: ActionGroupView

    /// The configuration object that defines the alert's appearance and behavior.
    ///
    /// This configuration determines the visual styling, layout behavior, and
    /// interaction patterns for the alert and its action buttons.
    private let configuration: ActionAlertableConfigurable

    /// Creates an action alert with the specified content and configuration.
    ///
    /// This initializer sets up the alert with the provided content and applies
    /// the specified configuration to determine the alert's appearance and behavior.
    /// If no configuration is provided, the global configuration is used.
    ///
    /// - Parameters:
    ///   - content: The content to display in the alert.
    ///   - configuration: An optional configuration object. If `nil`, the global configuration is used.
    public required init(
        content: AlertContent,
        configuration: ActionAlertableConfigurable? = nil
    ) {
        self.configuration = configuration ?? ActionAlert.Configuration.global
        let actionLayout = self.configuration.makeActionLayout()
        actionGroupView = ActionGroupView(content: content, actionLayout: actionLayout)
        super.init(content: actionGroupView)
        addListener(actionGroupView)

        layoutGuide = self.configuration.layoutGuide

        let decorator = ActionGroupAnimatorAndLayoutDecorator(
            aniamtor: AlertAnimator(),
            layoutModifier: AlertLayout(),
            actionGroupViews: [actionGroupView]
        )
        self.animator = decorator
        self.layout = decorator
    }

    /// Called before the alert container is laid out.
    ///
    /// This method applies the corner radius configuration to the action group view,
    /// ensuring that the alert has the proper visual styling as defined in the configuration.
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        actionGroupView.setCornerRadius(configuration.cornerRadius)
    }
}

/// An extension that provides methods for customizing the alert's background presentation.
///
/// This extension allows developers to customize the visual appearance of the alert's
/// background, providing flexibility in styling and visual effects.
extension ActionAlert {

    /// Sets a custom background view for the alert's presentation.
    ///
    /// This method allows you to provide a completely custom view as the background
    /// for the alert, enabling advanced visual effects and styling.
    ///
    /// - Parameter view: The custom view to use as the background.
    public func setPresentationBackground(view: UIView) {
        actionGroupView.backgroundView = view
    }

    /// Sets a solid color background for the alert's presentation.
    ///
    /// This method provides a convenient way to set a solid color background
    /// for the alert without creating a custom view.
    ///
    /// - Parameter color: The color to use for the background.
    public func setPresentationBackground(color: UIColor) {
        let view = UIView()
        view.backgroundColor = color
        setPresentationBackground(view: view)
    }
}

/// An extension that provides methods for managing actions within the alert.
///
/// This extension handles the addition and configuration of actions, including
/// proper ordering of cancel actions and view setup.
extension ActionAlert {

    /// Adds an action to the alert.
    ///
    /// This method adds a new action to the alert, ensuring proper validation
    /// and ordering. Cancel actions are automatically positioned according to
    /// platform conventions.
    ///
    /// - Parameter action: The action to add to the alert.
    public func addAction(_ action: Action) {
        guard canAddAction(action) else { return }

        actionGroupView.actions.append(action)
        setViewForAction(action)

        if let index = cancelActionIndex {
            let cancelAction = actionGroupView.actions.remove(at: index)
            // When there's only one action, place the cancel action first; otherwise, place it last.
            if actionGroupView.actions.count == 1 {
                actionGroupView.actions.insert(cancelAction, at: 0)
            } else {
                actionGroupView.actions.append(cancelAction)
            }
        }
    }

    /// Sets up the view for the specified action.
    ///
    /// This method creates and configures the visual representation for an action
    /// if one doesn't already exist, using the configuration's action view factory.
    ///
    /// - Parameter action: The action to set up a view for.
    private func setViewForAction(_ action: Action) {
        if action.view == nil {
            action.view = configuration.makeActionView(action.style)
            action.view?.title = action.title
        }
    }
}
