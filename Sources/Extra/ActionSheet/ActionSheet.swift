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
    public var actions: [Action] { normalActions + cancelActions }

    /// The action container view that holds all action content.
    private let actionContainerView = ActionSheet.ContainerView()

    /// Container for the standard (non-cancel) actions and optional custom content.
    private let normalWrapperView = UIView()

    /// Container for the cancel action group when configured with spacing.
    private let cancelWrapperView = UIView()

    /// Hosts the normal section's content and actions.
    private let normalChromeView = UIView()

    /// Hosts the cancel section's actions when needed.
    private let cancelChromeView = UIView()

    /// The representation sequence for standard actions.
    private let normalRepresentationView = ActionRepresentationSequenceView()

    /// The representation sequence for cancel actions.
    private let cancelRepresentationView = ActionRepresentationSequenceView()

    /// Separator between custom content and actions in the normal section.
    private lazy var normalSeparatorView: ActionVibrantSeparatorView = {
        let view = ActionVibrantSeparatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// The configuration object that defines the action sheet's appearance and behavior.
    private let configuration: ActionAlertableConfigurable

    /// Layout managers for each action section.
    private var normalActionLayout: ActionLayout
    private var cancelActionLayout: ActionLayout

    /// The stored actions for each section.
    private var normalActions: [Action] = []
    private var cancelActions: [Action] = []

    /// Background views for the normal and cancel sections.
    private var normalBackgroundView: UIView
    private var cancelBackgroundView: UIView

    /// Optional custom content displayed above the action list.
    private var customView: UIView?

    /// Optional content controller when the content was provided as a view controller.
    private weak var customController: UIViewController?

    /// Whether the sheet keeps cancel actions in a dedicated section.
    private let hasDedicatedCancelSection: Bool

    /// The spacing between the normal and cancel sections, if applicable.
    private let cancelSpacing: CGFloat

    /// Constraints used to keep sections attached to the container.
    private var normalBottomConstraint: NSLayoutConstraint?
    private var cancelTopConstraint: NSLayoutConstraint?

    /// Creates an action sheet with the specified content and configuration.
    ///
    /// This initializer sets up the action sheet with the provided content and applies
    /// the specified configuration for appearance and behavior. It configures separate
    /// action sections when cancel spacing is requested and ensures the correct layout
    /// and styling for each section.
    ///
    /// - Parameters:
    ///   - content: An optional content to display in the action sheet.
    ///   - configuration: An optional configuration object. If `nil`, the global configuration is used.
    public init(
        content: AlertContent? = nil,
        configuration: ActionAlertableConfigurable? = nil
    ) {
        self.configuration = configuration ?? ActionSheet.Configuration.global
        self.normalActionLayout = self.configuration.makeActionLayout()
        self.cancelActionLayout = self.configuration.makeActionLayout()
        self.normalBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        self.cancelBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        let spacing = self.configuration.value(for: "cancelSpacing") as? CGFloat ?? 0
        self.cancelSpacing = spacing
        self.hasDedicatedCancelSection = spacing > 1
        super.init(content: actionContainerView)
        configureHierarchy(with: content)
        layoutGuide = self.configuration.layoutGuide
        backdrop.allowDismissWhenBackgroundTouch = true
    }

    /// Called before the action sheet container is laid out.
    ///
    /// Applies section corner radii and refreshes the action layouts just before the
    /// layout pass completes so orientation changes are accounted for.
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        applyCornerRadius(configuration.cornerRadius)
        updateActionLayouts()
    }

    /// Called before the sheet is shown.
    open override func willShow() {
        super.willShow()
        ensureCustomControllerAttached()
        customController?.beginAppearanceTransition(true, animated: true)
    }

    /// Called after the sheet is shown.
    open override func didShow() {
        super.didShow()
        customController?.endAppearanceTransition()
    }

    /// Called before the sheet is dismissed.
    open override func willDismiss() {
        super.willDismiss()
        customController?.beginAppearanceTransition(false, animated: true)
    }

    /// Called after the sheet is dismissed.
    open override func didDismiss() {
        super.didDismiss()
        customController?.endAppearanceTransition()
    }
}

// MARK: - Public API

extension ActionSheet {

    /// Sets a custom background view for the specified section in the action sheet.
    ///
    /// - Parameters:
    ///   - view: The custom view to use as the background.
    ///   - section: Which section (normal or cancel) should use the background.
    public func setPresentationBackground(view: UIView, for section: ActionPresentationSection) {
        switch section {
        case .normal:
            replaceNormalBackground(with: view)
        case .cancel:
            replaceCancelBackground(with: view)
        }
        applyCornerRadius(configuration.cornerRadius)
    }

    /// Sets a solid color background for the specified section in the action sheet.
    ///
    /// - Parameters:
    ///   - color: The color to use for the background.
    ///   - section: Which section (normal or cancel) should use the background.
    public func setPresentationBackground(color: UIColor, for section: ActionPresentationSection) {
        let view = UIView()
        view.backgroundColor = color
        setPresentationBackground(view: view, for: section)
    }
}

// MARK: - Action management

extension ActionSheet {

    /// Adds an action to the action sheet.
    ///
    /// - Parameter action: The action to add to the action sheet.
    public func addAction(_ action: Action) {
        guard canAddAction(action) else { return }

        if hasDedicatedCancelSection {
            if action.style == .cancel {
                cancelActions = [action]
                setViewForAction(action)
            } else {
                normalActions.append(action)
                setViewForAction(action)
            }
        } else {
            normalActions.append(action)
            setViewForAction(action)

            if let index = cancelActionIndex {
                let cancelAction = normalActions.remove(at: index)
                if normalActions.count == 1 {
                    normalActions.insert(cancelAction, at: 0)
                } else {
                    normalActions.append(cancelAction)
                }
            }
        }

        refreshSections()
    }
}

// MARK: - Private helpers

private extension ActionSheet {

    var containerController: AlertContainerController? {
        presentedView.next as? AlertContainerController
    }

    func configureHierarchy(with content: AlertContent?) {
        setupRootHierarchy()
        applyContent(content)
        refreshSections()
    }

    func setupRootHierarchy() {
        setupNormalSection()
        if hasDedicatedCancelSection {
            setupCancelSection()
        }
    }

    func setupNormalSection() {
        normalWrapperView.translatesAutoresizingMaskIntoConstraints = false
        actionContainerView.addSubview(normalWrapperView)
        NSLayoutConstraint.activate([
            normalWrapperView.topAnchor.constraint(equalTo: actionContainerView.topAnchor),
            normalWrapperView.leftAnchor.constraint(equalTo: actionContainerView.leftAnchor),
            normalWrapperView.rightAnchor.constraint(equalTo: actionContainerView.rightAnchor)
        ])
        let bottom = normalWrapperView.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor)
        bottom.priority = .defaultHigh - 1
        bottom.isActive = true
        normalBottomConstraint = bottom

        installBackground(normalBackgroundView, in: normalWrapperView)

        normalChromeView.translatesAutoresizingMaskIntoConstraints = false
        normalWrapperView.addSubview(normalChromeView)
        NSLayoutConstraint.activate([
            normalChromeView.topAnchor.constraint(equalTo: normalWrapperView.topAnchor),
            normalChromeView.leftAnchor.constraint(equalTo: normalWrapperView.leftAnchor),
            normalChromeView.bottomAnchor.constraint(equalTo: normalWrapperView.bottomAnchor),
            normalChromeView.rightAnchor.constraint(equalTo: normalWrapperView.rightAnchor)
        ])
    }

    func setupCancelSection() {
        cancelWrapperView.translatesAutoresizingMaskIntoConstraints = false
        actionContainerView.addSubview(cancelWrapperView)
        NSLayoutConstraint.activate([
            cancelWrapperView.leftAnchor.constraint(equalTo: actionContainerView.leftAnchor),
            cancelWrapperView.rightAnchor.constraint(equalTo: actionContainerView.rightAnchor),
            cancelWrapperView.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor)
        ])
        let top = cancelWrapperView.topAnchor.constraint(equalTo: normalWrapperView.bottomAnchor, constant: cancelSpacing)
        top.isActive = true
        cancelTopConstraint = top

        installBackground(cancelBackgroundView, in: cancelWrapperView)

        cancelChromeView.translatesAutoresizingMaskIntoConstraints = false
        cancelWrapperView.addSubview(cancelChromeView)
        NSLayoutConstraint.activate([
            cancelChromeView.topAnchor.constraint(equalTo: cancelWrapperView.topAnchor),
            cancelChromeView.leftAnchor.constraint(equalTo: cancelWrapperView.leftAnchor),
            cancelChromeView.bottomAnchor.constraint(equalTo: cancelWrapperView.bottomAnchor),
            cancelChromeView.rightAnchor.constraint(equalTo: cancelWrapperView.rightAnchor)
        ])
    }

    func installBackground(_ background: UIView, in container: UIView) {
        background.clipsToBounds = true
        background.translatesAutoresizingMaskIntoConstraints = false
        container.insertSubview(background, at: 0)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: container.topAnchor),
            background.leftAnchor.constraint(equalTo: container.leftAnchor),
            background.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            background.rightAnchor.constraint(equalTo: container.rightAnchor)
        ])
    }

    func replaceNormalBackground(with view: UIView) {
        normalBackgroundView.removeFromSuperview()
        normalBackgroundView = view
        installBackground(normalBackgroundView, in: normalWrapperView)
    }

    func replaceCancelBackground(with view: UIView) {
        cancelBackgroundView.removeFromSuperview()
        cancelBackgroundView = view
        if hasDedicatedCancelSection {
            installBackground(cancelBackgroundView, in: cancelWrapperView)
        }
    }

    func applyContent(_ content: AlertContent?) {
        guard let content else { return }
        if let view = content as? UIView {
            customView = view
        } else if let controller = content as? UIViewController {
            customController = controller
            customView = controller.view
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

    func refreshSections() {
        rebuildNormalHierarchy()
        rebuildCancelHierarchy()
        updateActionLayouts()
        applyCornerRadius(configuration.cornerRadius)
    }

    func rebuildNormalHierarchy() {
        normalChromeView.subviews.forEach { $0.removeFromSuperview() }
        var nextTopAnchor = normalChromeView.topAnchor

        if let customView {
            customView.removeFromSuperview()
            normalChromeView.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                customView.topAnchor.constraint(equalTo: normalChromeView.topAnchor),
                customView.leftAnchor.constraint(equalTo: normalChromeView.leftAnchor),
                customView.rightAnchor.constraint(equalTo: normalChromeView.rightAnchor)
            ])
            let bottom = customView.bottomAnchor.constraint(equalTo: normalChromeView.bottomAnchor)
            bottom.priority = .defaultHigh - 1
            bottom.isActive = true
            nextTopAnchor = customView.bottomAnchor
        }

        guard !normalActions.isEmpty else { return }

        if customView != nil {
            normalChromeView.addSubview(normalSeparatorView)
            NSLayoutConstraint.activate([
                normalSeparatorView.topAnchor.constraint(equalTo: nextTopAnchor),
                normalSeparatorView.centerXAnchor.constraint(equalTo: normalChromeView.centerXAnchor),
                normalSeparatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
                normalSeparatorView.widthAnchor.constraint(equalTo: normalChromeView.widthAnchor)
            ])
            nextTopAnchor = normalSeparatorView.bottomAnchor
        }

        normalChromeView.addSubview(normalRepresentationView)
        NSLayoutConstraint.activate([
            normalRepresentationView.topAnchor.constraint(equalTo: nextTopAnchor),
            normalRepresentationView.centerXAnchor.constraint(equalTo: normalChromeView.centerXAnchor),
            normalRepresentationView.widthAnchor.constraint(equalTo: normalChromeView.widthAnchor),
            normalRepresentationView.bottomAnchor.constraint(equalTo: normalChromeView.bottomAnchor)
        ])
    }

    func rebuildCancelHierarchy() {
        guard hasDedicatedCancelSection else { return }
        cancelChromeView.subviews.forEach { $0.removeFromSuperview() }
        guard !cancelActions.isEmpty else { return }

        cancelChromeView.addSubview(cancelRepresentationView)
        NSLayoutConstraint.activate([
            cancelRepresentationView.topAnchor.constraint(equalTo: cancelChromeView.topAnchor),
            cancelRepresentationView.leftAnchor.constraint(equalTo: cancelChromeView.leftAnchor),
            cancelRepresentationView.bottomAnchor.constraint(equalTo: cancelChromeView.bottomAnchor),
            cancelRepresentationView.rightAnchor.constraint(equalTo: cancelChromeView.rightAnchor)
        ])
    }

    func updateActionLayouts() {
        updateNormalActionLayout()
        updateCancelActionLayout()
        normalSeparatorView.isHidden = normalActionLayout.prefersSeparatorHidden
    }

    func updateNormalActionLayout() {
        normalRepresentationView.separatableSequenceView.subviews.forEach { $0.removeFromSuperview() }
        guard !normalActions.isEmpty else { return }

        let buttons = normalActions.map { action -> UIView in
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

        normalActionLayout.layout(views: buttons, container: normalRepresentationView.separatableSequenceView)
    }

    func updateCancelActionLayout() {
        guard hasDedicatedCancelSection else { return }
        let spacing = cancelActions.isEmpty ? 0 : cancelSpacing
        cancelTopConstraint?.constant = spacing
        cancelRepresentationView.separatableSequenceView.subviews.forEach { $0.removeFromSuperview() }
        guard !cancelActions.isEmpty else { return }

        let buttons = cancelActions.map { action -> UIView in
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

        cancelActionLayout.layout(views: buttons, container: cancelRepresentationView.separatableSequenceView)
    }

    func applyCornerRadius(_ radius: CGFloat) {
        normalBackgroundView.layer.cornerCurve = .continuous
        normalBackgroundView.layer.cornerRadius = radius

        let normalSeparatableView = normalRepresentationView.separatableSequenceView
        if normalActions.count == 1, normalActions.first?.style == .cancel {
            normalSeparatableView.setCornerRadius(radius)
        } else if customView == nil {
            normalSeparatableView.setCornerRadius(radius)
        } else {
            normalSeparatableView.setCornerRadius(radius, corners: [.bottomLeft, .bottomRight])
        }

        if hasDedicatedCancelSection {
            cancelBackgroundView.layer.cornerCurve = .continuous
            cancelBackgroundView.layer.cornerRadius = radius
            cancelRepresentationView.separatableSequenceView.setCornerRadius(radius)
        }

        actionContainerView.layer.cornerCurve = .continuous
        actionContainerView.layer.cornerRadius = radius
        actionContainerView.layer.masksToBounds = true
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

/// A simple content view that can be used when no specific content is needed.
///
/// This class provides a minimal implementation of `AlertContent` that can be used
/// as a placeholder when no custom content is required for an action sheet.
public final class EmptyContentView: UIView, AlertContent { }
