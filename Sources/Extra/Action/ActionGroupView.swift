//
//  ActionGroupView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/6.
//

import UIKit

/// An enum that defines the different background domains for action presentations.
///
/// This enum is used to distinguish between different types of action presentations
/// and their associated background styling requirements.
public enum PresentationBackgroundDomain {
    /// The normal background domain for standard action presentations.
    case normal
    
    /// The cancel background domain for cancel action presentations.
    case cancel
}

/// A view that manages a group of actions and their presentation within an alert.
///
/// `ActionGroupView` is responsible for displaying and managing a collection of actions
/// within an alert context. It handles the layout, styling, and interaction of action buttons,
/// including support for custom content and proper lifecycle management.
class ActionGroupView: UIView, AlertContent {

    /// The array of actions to be displayed in this group.
    var actions: [Action] = []

    /// The layout manager responsible for positioning the action buttons.
    private var actionLayout: ActionLayout

    /// An optional custom view to be displayed above the actions.
    private let customView: UIView?

    /// An optional custom view controller to be displayed above the actions.
    private let customController: UIViewController?

    /// The background view that provides the visual backdrop for the action group.
    ///
    /// When set, this property automatically configures the background view with proper
    /// clipping, frame, and autoresizing settings, and inserts it as the bottommost subview.
    var backgroundView: UIView {
        didSet {
            oldValue.removeFromSuperview()
            backgroundView.clipsToBounds = true
            backgroundView.frame = bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(backgroundView, at: 0)
        }
    }

    /// The view that manages the sequence of action representations.
    private let representationSequenceView = ActionRepresentationSequenceView()

    /// A separator view that provides visual separation between content and actions.
    private lazy var separatorView = ActionVibrantSeparatorView()

    /// A container view that holds all the content and action views.
    private let containerView = UIView()

    /// Creates a new action group view with the specified content and layout.
    ///
    /// This initializer sets up the action group view with the provided content and layout manager.
    /// It handles both UIView and UIViewController content types, setting up the proper hierarchy.
    ///
    /// - Parameters:
    ///   - content: The alert content to display above the actions. Can be a UIView or UIViewController.
    ///   - actionLayout: The layout manager responsible for positioning the action buttons.
    required init(content: AlertContent?, actionLayout: ActionLayout) {
        self.actionLayout = actionLayout
        self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        if let view = content as? UIView {
            self.customView = view
            self.customController = nil
        } else if let viewController = content as? UIViewController {
            self.customView = viewController.view
            self.customController = viewController
        } else {
            self.customView = nil
            self.customController = nil
        }

        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerCurve = .continuous
        super.init(frame: .zero)
        backgroundView.frame = bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backgroundView)

        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(containerView)
    }

    /// Called when the view is added to or removed from a superview.
    ///
    /// This method handles the setup of the view hierarchy when the action group view
    /// is added to a superview. It manages the layout of custom content, separators,
    /// and action representations with proper constraints.
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }

        containerView.subviews.forEach { $0.removeFromSuperview() }

        if let customView {
            if let customController, let alertContainerController {
                customController.willMove(toParent: alertContainerController)
                alertContainerController.addChild(customController)
                containerView.addSubview(customView)
                customController.didMove(toParent: alertContainerController)
            } else {
                containerView.addSubview(customView)
            }

            customView.translatesAutoresizingMaskIntoConstraints = false

            customView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            customView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            customView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            let customBottomConstraint = customView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            customBottomConstraint.priority = .defaultHigh - 1
            customBottomConstraint.isActive = true
        }

        if !actions.isEmpty {
            separatorView.removeFromSuperview()
            if let customView {
                containerView.addSubview(separatorView)
                separatorView.topAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
                separatorView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
                separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            }

            representationSequenceView.removeFromSuperview()
            containerView.addSubview(representationSequenceView)
            if customView != nil {
                representationSequenceView.topAnchor.constraint(equalTo: separatorView.bottomAnchor).isActive = true
            } else {
                representationSequenceView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            }
            representationSequenceView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            representationSequenceView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            representationSequenceView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        }
    }

    /// This initializer is not supported and will cause a fatal error.
    ///
    /// - Parameter coder: The NSCoder instance (unused).
    /// - Returns: This method always calls `fatalError`.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the layout of the action buttons based on the current interface orientation.
    ///
    /// This method recreates the action button representations and applies the current
    /// layout configuration. It handles the creation of custom view representations
    /// for each action and sets up the proper target-action relationships.
    ///
    /// - Parameter interfaceOrientation: The current interface orientation.
    func updateLayout(interfaceOrientation: UIInterfaceOrientation) {
        representationSequenceView.separatableSequenceView.subviews.forEach {
            $0.removeFromSuperview()
        }
        guard !actions.isEmpty else { return }

        let buttons = actions.map { action -> UIView in
            if let representationView = action.representationView {
                return representationView
            }

            let button = ActionCustomViewRepresentationView()
            defer { action.representationView = button }
            button.action = action
            button.isEnabled = action.isEnabled
            let selector = #selector(handleActionButtonTouchUpInside(_:))
            button.removeTarget(self, action: selector, for: .touchUpInside)
            button.addTarget(self, action: selector, for: .touchUpInside)
            return button
        }
        separatorView.isHidden = actionLayout.prefersSeparatorHidden
        let separatableSequenceView = representationSequenceView.separatableSequenceView
        actionLayout.layout(views: buttons, container: separatableSequenceView)
    }

    /// Handles the touch up inside event for action buttons.
    ///
    /// This method is called when a user taps on an action button. It executes the
    /// action's handler and optionally dismisses the alert if the action is configured
    /// to auto-dismiss.
    ///
    /// - Parameter button: The action button that was tapped.
    @objc
    private func handleActionButtonTouchUpInside(_ button: ActionCustomViewRepresentationView) {
        if let action = button.action {
            action.handler?(action)
            if action.autoDismissesOnAction {
                dismiss(completion: nil)
            }
        }
    }

    /// Sets the corner radius for the action group view and its components.
    ///
    /// This method applies the specified corner radius to the background view and
    /// the representation sequence view, with special handling for single cancel
    /// actions and custom content.
    ///
    /// - Parameter radius: The corner radius to apply.
    func setCornerRadius(_ radius: CGFloat) {
        backgroundView.layer.cornerCurve = .continuous
        backgroundView.layer.cornerRadius = radius
        let view = representationSequenceView.separatableSequenceView
        if (actions.count == 1 && actions[0].style == .cancel) || customView == nil {
            view.setCornerRadius(radius)
        } else {
            view.setCornerRadius(radius, corners: [.bottomLeft, .bottomRight])
        }
    }

    /// Finds the alert container controller in the view hierarchy.
    ///
    /// This method traverses the view hierarchy to find the nearest
    /// `AlertContainerController` that contains this action group view.
    ///
    /// - Returns: The alert container controller if found, otherwise `nil`.
    private var alertContainerController: AlertContainerController? {
        for view in sequence(first: superview, next: { $0?.superview }) {
            if let responder = view?.next as? AlertContainerController {
                return responder
            }
        }
        return nil
    }
}

/// An extension that provides lifecycle management for the action group view.
///
/// This extension implements the `LifecycleListener` protocol to handle the
/// appearance and disappearance of custom view controllers within the action group.
extension ActionGroupView: LifecycleListener {

    /// Called before the action group view is shown.
    ///
    /// This method begins the appearance transition for any custom view controller
    /// that is part of this action group view.
    func willShow() {
        if let customController {
            customController.beginAppearanceTransition(true, animated: true)
        }
    }

    /// Called after the action group view has been shown.
    ///
    /// This method ends the appearance transition for any custom view controller
    /// that is part of this action group view.
    func didShow() {
        if let customController {
            customController.endAppearanceTransition()
        }
    }

    /// Called before the action group view is dismissed.
    ///
    /// This method begins the disappearance transition for any custom view controller
    /// that is part of this action group view.
    func willDismiss() {
        if let customController {
            customController.beginAppearanceTransition(false, animated: true)
        }
    }

    /// Called after the action group view has been dismissed.
    ///
    /// This method ends the disappearance transition for any custom view controller
    /// that is part of this action group view.
    func didDismiss() {
        if let customController {
            customController.endAppearanceTransition()
        }
    }
}
