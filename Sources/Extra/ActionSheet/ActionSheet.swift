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
/// The action sheet supports both regular actions and cancel actions, with proper separation
/// and visual styling for different action types.
open class ActionSheet: Sheet, ActionAlertable {

    /// The array of all actions available in this action sheet.
    ///
    /// This property combines both regular actions and cancel actions into a single array,
    /// providing a unified interface for accessing all actions in the sheet.
    public var actions: [Action] { actionGroupView.actions + cancelActionGroupView.actions }

    /// The action container view that holds all action group views.
    ///
    /// This view serves as the main container for both regular and cancel action groups,
    /// managing their layout and visual separation within the action sheet.
    private let actionContainerView = ActionSheet.ContainerView()

    /// The view that manages the group of regular action buttons.
    ///
    /// This view handles the display and layout of all non-cancel actions,
    /// including proper spacing, separators, and visual styling.
    private let actionGroupView: ActionGroupView

    /// The view that manages the group of cancel action buttons.
    ///
    /// This view handles the display and layout of cancel actions, which are typically
    /// separated from regular actions with additional spacing for visual distinction.
    private var cancelActionGroupView: ActionGroupView

    /// The configuration object that defines the action sheet's appearance and behavior.
    ///
    /// This configuration determines the visual styling, layout behavior, and
    /// interaction patterns for the action sheet and its action buttons.
    private let configuration: ActionAlertableConfigurable

    /// Creates an action sheet with the specified content and configuration.
    ///
    /// This initializer sets up the action sheet with the provided content and applies
    /// the specified configuration for appearance and behavior. It creates separate
    /// action group views for regular and cancel actions, and configures the
    /// appropriate animator and layout decorators.
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
        super.init(content: actionContainerView)
        addListener(actionGroupView)

        layoutGuide = self.configuration.layoutGuide

        let decorator = ActionGroupAnimatorAndLayoutDecorator(
            animator: animator,
            layoutModifier: layout,
            actionGroupViews: [actionGroupView, cancelActionGroupView]
        )
        animator = decorator
        layout = decorator
        backdrop.allowDismissWhenBackgroundTouch = true
    }

    /// Called before the action sheet container is laid out.
    ///
    /// This method configures the action group container layout and applies corner radius styling.
    /// It handles the visual separation between regular and cancel actions, and ensures
    /// proper corner radius application for the container and action groups.
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        configureActionGroupContainer()
        if let cancelSpacing = configuration.value(for: "cancelSpacing") as? CGFloat,
           cancelSpacing > 1 {
            actionGroupView.setCornerRadius(configuration.cornerRadius)
            cancelActionGroupView.setCornerRadius(configuration.cornerRadius)
        }
        actionContainerView.layer.cornerCurve = .continuous
        actionContainerView.layer.cornerRadius = configuration.cornerRadius
        actionContainerView.layer.masksToBounds = true
    }
}

/// An extension that provides methods for customizing the action sheet's background presentation.
///
/// This extension allows developers to customize the visual appearance of the action sheet's
/// background for both normal and cancel action domains, providing flexibility in styling.
extension ActionSheet {

    /// Sets a custom background view for the specified domain in the action sheet.
    ///
    /// This method allows you to provide a completely custom view as the background
    /// for either the normal actions or cancel actions, enabling advanced visual effects.
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
    /// This method provides a convenient way to set a solid color background
    /// for either the normal actions or cancel actions without creating a custom view.
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

/// An extension that provides container configuration methods for action sheets.
///
/// This extension handles the layout and positioning of action group views within
/// the container, including proper spacing and constraint management.
extension ActionSheet {

    /// Configures the layout of action group views within the container.
    ///
    /// This method sets up the constraints for both regular and cancel action groups,
    /// ensuring proper positioning and spacing between them. It handles the visual
    /// separation between action types based on the configuration settings.
    private func configureActionGroupContainer() {
        if actionGroupView.superview != actionContainerView {
            actionContainerView.addSubview(actionGroupView)
            actionGroupView.translatesAutoresizingMaskIntoConstraints = false

            actionGroupView.leftAnchor.constraint(equalTo: actionContainerView.leftAnchor).isActive = true
            actionGroupView.rightAnchor.constraint(equalTo: actionContainerView.rightAnchor).isActive = true
            actionGroupView.topAnchor.constraint(equalTo: actionContainerView.topAnchor).isActive = true
            let constraint = actionGroupView.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor)
            constraint.priority = .defaultHigh - 1
            constraint.isActive = true
        }

        if let cancelSpacing = configuration.value(for: "cancelSpacing") as? CGFloat,
           cancelSpacing > 1, cancelActionGroupView.superview != actionContainerView {
            actionContainerView.addSubview(cancelActionGroupView)
            cancelActionGroupView.translatesAutoresizingMaskIntoConstraints = false

            cancelActionGroupView.leftAnchor.constraint(equalTo: actionContainerView.leftAnchor).isActive = true
            cancelActionGroupView.rightAnchor.constraint(equalTo: actionContainerView.rightAnchor).isActive = true
            cancelActionGroupView.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor).isActive = true
            let constraint = cancelActionGroupView.topAnchor.constraint(equalTo: actionGroupView.bottomAnchor, constant: cancelSpacing)
            constraint.isActive = true
        }
    }
}

/// An extension that provides methods for managing actions within the action sheet.
///
/// This extension handles the addition and configuration of actions, including
/// proper ordering of cancel actions and view setup for different action types.
extension ActionSheet {

    /// Adds an action to the action sheet.
    ///
    /// This method adds a new action to the appropriate action group based on its style.
    /// Cancel actions are placed in the cancel action group when spacing is configured,
    /// while other actions are placed in the regular action group. The method ensures
    /// proper validation and ordering according to platform conventions.
    ///
    /// - Parameter action: The action to add to the action sheet.
    public func addAction(_ action: Action) {
        guard canAddAction(action) else { return }

        if let cancelSpacing = configuration.value(for: "cancelSpacing") as? CGFloat,
            cancelSpacing > 1 {
            // Cancel actions are placed in `cancelActionGroupView.actions`, while other action types
            // are placed in `actionGroupView.actions`. The `cancelActionGroupView.actions` count is 0 or 1.
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
                // When there's only one action, place the cancel action first; otherwise, place it last.
                if actionGroupView.actions.count == 1 {
                    actionGroupView.actions.insert(cancelAction, at: 0)
                } else {
                    actionGroupView.actions.append(cancelAction)
                }
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

/// A simple content view that can be used when no specific content is needed.
///
/// This class provides a minimal implementation of `AlertContent` that can be used
/// as a placeholder when no custom content is required for an action sheet.
public final class EmptyContentView: UIView, AlertContent { }
