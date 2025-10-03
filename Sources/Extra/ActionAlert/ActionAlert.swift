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

    private final class ContentView: UIView, AlertContent { }

    /// The array of actions available in this alert.
    ///
    /// This property provides access to all actions that have been added to the alert.
    public var actions: [Action] { actionStorage }

    /// Hosts the full content hierarchy (custom content + action representations).
    private let contentView = ContentView()

    /// Container that holds custom content and the representation sequence view.
    private let chromeView = UIView()

    /// The representation sequence that renders individual action views.
    private let representationSequenceView = ActionRepresentationSequenceView()

    /// Optional separator between custom content and the actions list.
    private lazy var separatorView: ActionVibrantSeparatorView = {
        let view = ActionVibrantSeparatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// The configuration object that defines the alert's appearance and behavior.
    private let configuration: ActionAlertableConfigurable

    /// The layout responsible for arranging action representations.
    private var actionLayout: ActionLayout

    /// The backing storage for actions.
    private var actionStorage: [Action] = []

    /// The active background view shown behind content and actions.
    private var backgroundView: UIView

    /// The custom content supplied when the alert was created.
    private var customView: UIView?

    /// The custom controller supplied when the alert was created (if any).
    private weak var customController: UIViewController?

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
        self.actionLayout = self.configuration.makeActionLayout()
        self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        super.init(content: contentView)
        configureHierarchy(with: content)
        layoutGuide = self.configuration.layoutGuide
    }

    /// Called before the alert container is laid out.
    ///
    /// Applies the configured corner radius and ensures the latest action layout
    /// is reflected before Auto Layout finalises the geometry.
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        applyCornerRadius(configuration.cornerRadius)
        updateActionLayout()
    }

    /// Called before the alert is shown.
    open override func willShow() {
        super.willShow()
        ensureCustomControllerAttached()
        customController?.beginAppearanceTransition(true, animated: true)
    }

    /// Called after the alert is shown.
    open override func didShow() {
        super.didShow()
        customController?.endAppearanceTransition()
    }

    /// Called before the alert is dismissed.
    open override func willDismiss() {
        super.willDismiss()
        customController?.beginAppearanceTransition(false, animated: true)
    }

    /// Called after the alert is dismissed.
    open override func didDismiss() {
        super.didDismiss()
        customController?.endAppearanceTransition()
    }
}

// MARK: - Public API

extension ActionAlert {

    /// Sets a custom background view for the alert's presentation.
    ///
    /// This method allows you to provide a completely custom view as the background
    /// for the alert, enabling advanced visual effects and styling.
    ///
    /// - Parameter view: The custom view to use as the background.
    public func setPresentationBackground(view: UIView) {
        replaceBackgroundView(with: view)
        applyCornerRadius(configuration.cornerRadius)
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

        actionStorage.append(action)
        setViewForAction(action)

        if let index = cancelActionIndex {
            let cancelAction = actionStorage.remove(at: index)
            if actionStorage.count == 1 {
                actionStorage.insert(cancelAction, at: 0)
            } else {
                actionStorage.append(cancelAction)
            }
        }

        rebuildHierarchy()
        updateActionLayout()
        applyCornerRadius(configuration.cornerRadius)
    }
}

// MARK: - Private helpers

private extension ActionAlert {

    var containerController: AlertContainerController? {
        presentedView.next as? AlertContainerController
    }

    func configureHierarchy(with content: AlertContent?) {
        setupRootHierarchy()
        applyContent(content)
        rebuildHierarchy()
        updateActionLayout()
        applyCornerRadius(configuration.cornerRadius)
    }

    func setupRootHierarchy() {
        contentView.backgroundColor = .clear

        installBackgroundView()

        chromeView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(chromeView)
        NSLayoutConstraint.activate([
            chromeView.topAnchor.constraint(equalTo: contentView.topAnchor),
            chromeView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            chromeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            chromeView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }

    func installBackgroundView() {
        backgroundView.clipsToBounds = true
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.insertSubview(backgroundView, at: 0)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }

    func replaceBackgroundView(with view: UIView) {
        backgroundView.removeFromSuperview()
        backgroundView = view
        installBackgroundView()
    }

    func applyContent(_ content: AlertContent?) {
        guard let content else {
            customView = nil
            customController = nil
            return
        }

        if let view = content as? UIView {
            customView = view
            customController = nil
        } else if let controller = content as? UIViewController {
            customController = controller
            customView = controller.view
        } else {
            customView = nil
            customController = nil
        }

        ensureCustomControllerAttached()
    }

    func ensureCustomControllerAttached() {
        guard let controller = customController,
              let containerController = containerController,
              controller.parent !== containerController else {
            return
        }
        controller.willMove(toParent: containerController)
        containerController.addChild(controller)
        controller.didMove(toParent: containerController)
    }

    func rebuildHierarchy() {
        chromeView.subviews.forEach { $0.removeFromSuperview() }

        var nextTopAnchor = chromeView.topAnchor

        if let customView {
            customView.removeFromSuperview()
            chromeView.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                customView.topAnchor.constraint(equalTo: chromeView.topAnchor),
                customView.leftAnchor.constraint(equalTo: chromeView.leftAnchor),
                customView.rightAnchor.constraint(equalTo: chromeView.rightAnchor)
            ])
            let bottomConstraint = customView.bottomAnchor.constraint(equalTo: chromeView.bottomAnchor)
            bottomConstraint.priority = .defaultHigh - 1
            bottomConstraint.isActive = true
            nextTopAnchor = customView.bottomAnchor
        }

        guard !actionStorage.isEmpty else { return }

        if customView != nil {
            chromeView.addSubview(separatorView)
            NSLayoutConstraint.activate([
                separatorView.topAnchor.constraint(equalTo: nextTopAnchor),
                separatorView.centerXAnchor.constraint(equalTo: chromeView.centerXAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
                separatorView.widthAnchor.constraint(equalTo: chromeView.widthAnchor)
            ])
            nextTopAnchor = separatorView.bottomAnchor
        }

        representationSequenceView.removeFromSuperview()
        chromeView.addSubview(representationSequenceView)
        NSLayoutConstraint.activate([
            representationSequenceView.topAnchor.constraint(equalTo: nextTopAnchor),
            representationSequenceView.centerXAnchor.constraint(equalTo: chromeView.centerXAnchor),
            representationSequenceView.widthAnchor.constraint(equalTo: chromeView.widthAnchor),
            representationSequenceView.bottomAnchor.constraint(equalTo: chromeView.bottomAnchor)
        ])
    }

    func updateActionLayout() {
        representationSequenceView.separatableSequenceView.subviews.forEach { $0.removeFromSuperview() }
        guard !actionStorage.isEmpty else { return }

        let buttons = actionStorage.map { action -> UIView in
            if let view = action.representationView {
                return view
            }

            let button = ActionCustomViewRepresentationView()
            defer { action.representationView = button }
            button.action = action
            button.isEnabled = action.isEnabled
            button.removeTarget(self, action: #selector(handleActionButtonTouchUpInside(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(handleActionButtonTouchUpInside(_:)), for: .touchUpInside)
            return button
        }

        separatorView.isHidden = actionLayout.prefersSeparatorHidden
        actionLayout.layout(views: buttons, container: representationSequenceView.separatableSequenceView)
    }

    func applyCornerRadius(_ radius: CGFloat) {
        backgroundView.layer.cornerCurve = .continuous
        backgroundView.layer.cornerRadius = radius

        let separatableView = representationSequenceView.separatableSequenceView
        if actionStorage.count == 1, actionStorage.first?.style == .cancel {
            separatableView.setCornerRadius(radius)
        } else if customView == nil {
            separatableView.setCornerRadius(radius)
        } else {
            separatableView.setCornerRadius(radius, corners: [.bottomLeft, .bottomRight])
        }
    }

    func setViewForAction(_ action: Action) {
        if action.view == nil {
            action.view = configuration.makeActionView(action.style)
            action.view?.title = action.title
        }
    }

    @objc
    func handleActionButtonTouchUpInside(_ button: ActionCustomViewRepresentationView) {
        guard let action = button.action else { return }
        action.handler?(action)
        if action.autoDismissesOnAction {
            dismiss(completion: nil)
        }
    }
}
