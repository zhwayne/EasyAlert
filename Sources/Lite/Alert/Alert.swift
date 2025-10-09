//
//  Alert.swift
//  EasyAlert
//
//  Created by iya on 2021/7/27.
//

import UIKit

/// The base alert class that provides core alert functionality.
///
/// `Alert` is the fundamental class for displaying modal dialogs and overlays in your app.
/// It manages the presentation, animation, and dismissal of alert content with customizable
/// backdrop, layout, and animation behaviors.
@MainActor open class Alert: Alertable {

    /// The content to be displayed in the alert.
    ///
    /// This can be either a `UIView` or `UIViewController` that provides the alert's content.
    public let alertContent: AlertContent

    /// The backdrop provider that manages the alert's background appearance and interaction.
    ///
    /// The backdrop controls the visual appearance behind the alert and handles user interactions
    /// with the background area.
    public var backdrop: AlertBackdrop = DefaultAlertBackdropProvider() {
        didSet { configureDimming() }
    }

    /// The animator responsible for showing and dismissing the alert.
    ///
    /// This animator controls the transition animations when the alert appears and disappears.
    public var animator: AlertbleAnimator = AlertAnimator()

    /// The layout guide that defines the alert's size constraints.
    ///
    /// This guide determines how the alert is sized and positioned within its container.
    public var layoutGuide = LayoutGuide(width: .flexible, height: .flexible) {
        didSet {
            guard isActive else { return }
            updateLayout()
         }
    }

    /// The layout manager that handles the alert's positioning and sizing.
    ///
    /// This layout manager is responsible for calculating and applying the alert's final position.
    public var layout: AlertableLayout = AlertLayout()

    /// A Boolean value indicating whether the alert is currently active and visible.
    ///
    /// This property is `true` when the alert is being displayed and `false` when it's dismissed.
    public private(set) var isActive: Bool = false
    
    /// The backdrop view that provides the visual background for the alert.
    ///
    /// This view serves as the main container for the entire alert presentation,
    /// including the dimming background and the alert content. It provides the
    /// coordinate system for layout calculations and is accessible for custom
    /// animations, gesture recognizers, and layout modifications.
    public var containerView: UIView {
        return backdropView
    }
    
    /// The presented view that contains the actual alert content.
    ///
    /// This view represents the actual content area of the alert. This view
    /// is the one that gets animated during show and dismiss transitions.
    public var presentedView: UIView {
        return alertContainerController.view
    }
    
    /// The container controller that manages the alert's view hierarchy.
    private lazy var alertContainerController = AlertContainerController(alert: self)

    /// The backdrop view that provides the visual background for the alert.
    private let backdropView = DimmingKnockoutBackdropView()

    /// The dimming view that creates the darkened background effect.
    private let dimmingView = DimmingView()

    /// The tap target that handles background tap gestures.
    private let tapTarget = TapTarget()

    /// The keyboard event monitor that tracks keyboard show/hide events.
    private let keyboardEventMonitor = KeyboardEventMonitor()

    /// The collection of lifecycle listeners that receive alert lifecycle notifications.
    private var lifecycleListeners: [LifecycleListener] = []

    /// The notification token for device orientation changes.
    private var orientationChangeToken: NotificationToken?

    /// The window used to display the alert when no specific hosting view is provided.
    private var window: AlertWindow?

    #if DEBUG
    deinit {
        print("deinit \(self)")
    }
    #endif

    /// Creates an alert with the specified content.
    ///
    /// - Parameter content: The content to display in the alert. Must be either a `UIView` or `UIViewController`.
    /// - Throws: A fatal error if the content type is not supported.
    public init(content: AlertContent) {
        guard content is UIView || content is UIViewController else {
            fatalError("Unsupported type: \(type(of: content))")
        }
        self.alertContent = content
    }

    private func observeDeviceRotation() {
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        orientationChangeToken = NotificationCenter.default.observe(
            name: UIDevice.orientationDidChangeNotification,
            object: nil,
            using: { [weak self] note in
                guard let self, isActive else { return }
                DispatchQueue.main.async {
                    self.updateLayout()
                }
            })
    }

    private func observeKeyboardEvent() {
        keyboardEventMonitor.keyboardWillShow = { [weak self] info in
            guard let self, isActive else { return }
            // TODO: 处理键盘事件
        }
        keyboardEventMonitor.keyboardWillHide = { [weak self] info in
            guard let self, isActive else { return }
            // TODO: 处理键盘事件
        }
    }

    private func configureBackdrop() {
        backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backdropView.addGestureRecognizer(tapTarget.tapGestureRecognizer)
        backdropView.hitTest = { [unowned self] view, point in
            switch backdrop.interactionScope {
            case .none: return false
            case .all: return true
            case .dimming:
                let point = view.convert(point, to: alertContainerController.view)
                return !alertContainerController.view.bounds.contains(point)
            }
        }
        backdropView.willRemoveFromSuperviewObserver = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss()
            }
        }

        tapTarget.gestureRecognizerShouldBeginBlock = { [unowned self] gestureRecognizer in
            guard let backgroundView = gestureRecognizer.view else { return false }
            let point = gestureRecognizer.location(in: backgroundView)
            return !alertContainerController.view.frame.contains(point)
        }
        tapTarget.tapHandler = { [unowned self] in
            backdropView.endEditing(false)
            if backdrop.allowDismissWhenBackgroundTouch {
                DispatchQueue.main.async {
                    self.dismiss()
                }
            }
        }
    }

    /// Adds a lifecycle listener to receive alert lifecycle notifications.
    ///
    /// - Parameter listener: The listener to add to the alert's lifecycle events.
    public func addListener(_ listener: LifecycleListener) {
        lifecycleListeners.append(listener)
    }

    /// Presents the alert with optional hosting view.
    ///
    /// - Parameter hosting: An optional view or view controller to host the alert. If `nil`, the alert will be displayed in a new window.
    public func show(in hosting: AlertHosting? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard !isActive else { return }
        observeKeyboardEvent()
        observeDeviceRotation()
        configureBackdrop()
        configureDimming()
        configureContainer()
        presentAlert(in: hosting)
    }

    /// Dismisses the alert with an optional completion handler.
    ///
    /// - Parameter completion: An optional closure to execute when the dismissal animation completes.
    public func dismiss(completion: (() -> Void)? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard isActive else { return }
        hideAlert(completion: completion)
    }

    /// Dismisses the alert asynchronously.
    ///
    /// - Returns: An async operation that completes when the alert is fully dismissed.
    public func dismiss() async {
        await withUnsafeContinuation({ continuation in
            dismiss { continuation.resume() }
        })
    }

    /// Called before the alert is shown.
    ///
    /// Override this method to perform any setup before the alert appears.
    open func willShow() { }

    /// Called after the alert is shown.
    ///
    /// Override this method to perform any actions after the alert appears.
    open func didShow() { }

    /// Called before the alert is dismissed.
    ///
    /// Override this method to perform any cleanup before the alert disappears.
    open func willDismiss() { }

    /// Called after the alert is dismissed.
    ///
    /// Override this method to perform any final actions after the alert disappears.
    open func didDismiss() { }

    /// Called before the alert container is laid out.
    ///
    /// Override this method to perform any setup before the alert's layout is calculated.
    open func willLayoutContainer() { }

    /// Called after the alert container is laid out.
    ///
    /// Override this method to perform any actions after the alert's layout is calculated.
    open func didLayoutContainer() { }
}

extension Alert {

    private func setupWindow() {
        if window == nil, let windowScene = UIApplication.shared.activeWindowScene {
            window = AlertWindow(windowScene: windowScene)
            if let keyWindow = windowScene.keyWindowBacked {
                let userInterfaceStyle = keyWindow.traitCollection.userInterfaceStyle
                window?.overrideUserInterfaceStyle = userInterfaceStyle
            }
        }
        if window == nil {
            // Fallback
            window = AlertWindow(frame: UIScreen.main.bounds)
        }
        window?.rootViewController = UIViewController()
        window?.backgroundColor = .clear
        window?.windowLevel = .alert - 1
        window?.isHidden = false
    }

    private func configureDimming() {
        switch backdrop.dimming {
        case let .color(color): dimmingView.backgroundColor = color
        case let .view(view):   dimmingView.contentView = view
        case let .blur(style, radius):
            let blurView = BlurEffectView(frame: .zero)
            blurView.blurRadius = radius
            blurView.colorTint = style.color
            dimmingView.contentView = blurView
        }
        dimmingView.isUserInteractionEnabled = false
        dimmingView.frame = backdropView.bounds
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backdropView.insertSubview(dimmingView, at: 0)
    }

    private func configureContainer() {
        let contentContainerView = alertContainerController.view!
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.autoresizingMask = []
        backdropView.addSubview(contentContainerView)

        // Add view or viewController
        if let view = alertContent as? UIView {
            contentContainerView.addSubview(view)
            layoutFill(view)
        } else if let viewController = alertContent as? UIViewController {
            viewController.willMove(toParent: alertContainerController)
            alertContainerController.addChild(viewController)
            contentContainerView.addSubview(viewController.view)
            viewController.didMove(toParent: alertContainerController)
            layoutFill(viewController.view)
        }
    }

    private func layoutFill(_ view: UIView) {
        guard let superview = view.superview else {
            fatalError()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
    }

    public func updateLayout() {
        willLayoutContainer()
        presentedView.translatesAutoresizingMaskIntoConstraints = false
        layout.updateLayoutConstraints(context: layoutContext, layoutGuide: layoutGuide)
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
        didLayoutContainer()
    }

    private func performShowWithAnimation() {
        isActive = true
        willShow()
        lifecycleListeners.forEach { $0.willShow() }
        if let viewController = alertContent as? UIViewController {
            viewController.beginAppearanceTransition(true, animated: true)
        }

        alertContainerController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        animator.show(context: layoutContext) { [weak self] in
            self?.didShow()
            self?.lifecycleListeners.forEach { $0.didShow() }
            self?.alertContainerController.view.isUserInteractionEnabled = true
            self?.tapTarget.tapGestureRecognizer.isEnabled = true
            if let viewController = self?.alertContent as? UIViewController {
                viewController.endAppearanceTransition()
            }
        }
    }

    private func _presentAlert(in view: UIView) {
        backdropView.frame = view.bounds
        view.addSubview(backdropView)
        updateLayout()
        performShowWithAnimation()
    }

    private func _presentAlert(in viewController: UIViewController) {
        backdropView.frame = viewController.view.bounds
        viewController.view.addSubview(backdropView)
        updateLayout()
        performShowWithAnimation()
    }

    private func presentAlert(in parent: AlertHosting?) {
        if let view = parent as? UIView {
            view.attach(alert: self)
            _presentAlert(in: view)
        } else if let viewController = parent as? UIViewController {
            viewController.view.attach(alert: self)
            _presentAlert(in: viewController)
        } else {
            setupWindow()
            if let viewController = window?.rootViewController {
                window?.attach(alert: self)
                _presentAlert(in: viewController)
            }
        }
    }
}

extension Alert {

    private func hideAlert(completion: (() -> Void)?) {
        isActive = false
        willDismiss()
        lifecycleListeners.forEach { $0.willDismiss() }
        if let viewController = alertContent as? UIViewController {
            viewController.beginAppearanceTransition(false, animated: true)
        }

        alertContainerController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        animator.dismiss(context: layoutContext) { [weak self] in
            self?.didDismiss()
            self?.lifecycleListeners.forEach { $0.didDismiss() }
            if let viewController = self?.alertContent as? UIViewController {
                viewController.endAppearanceTransition()
            }
            completion?()
            self?.clean()
            self?.alertContainerController.view.isUserInteractionEnabled = true
            self?.tapTarget.tapGestureRecognizer.isEnabled = true
        }
    }

    private func clean() {
        if let view = alertContent as? UIView {
            view.removeFromSuperview()
        } else if let viewController = alertContent as? UIViewController {
            viewController.removeFromParent()
            viewController.view.removeFromSuperview()
            viewController.didMove(toParent: nil)
        }
        if let parent = backdropView.superview {
            parent.detach(alert: self)
            alertContainerController.view.removeFromSuperview()
            backdropView.removeFromSuperview()
        }
        window?.isHidden = true
        window = nil
    }
}

extension Alert {

    private var interfaceOrientation: UIInterfaceOrientation {
        let windowScene = UIApplication.shared.activeWindowScene
        return windowScene?.interfaceOrientation ?? .portrait
    }

    private var layoutContext: LayoutContext {
        LayoutContext(
            containerView: backdropView,
            dimmingView: dimmingView,
            presentedView: alertContainerController.view,
            interfaceOrientation: interfaceOrientation
        )
    }
}

extension UIApplication {

    var activeWindowScene: UIWindowScene? {
        let windowScenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        return windowScenes.first { $0.activationState == .foregroundActive }
    }
}

extension UIWindowScene {

    var keyWindowBacked: UIWindow? {
        if #available(iOS 15.0, *) {
            return self.keyWindow
        } else {
            return self.windows.first { $0.isKeyWindow }
        }
    }
}
