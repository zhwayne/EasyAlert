//
//  Alert.swift
//  EasyAlert
//
//  Created by iya on 2021/7/27.
//

import UIKit


/// The base alert.
@MainActor open class Alert: Alertable {
    
    public let alertContent: AlertContent
    
    /// A Provider that interacts with the backdrop
    public var backdrop: AlertBackdrop = DefaultAlertBackdropProvider() {
        didSet { configDimming() }
    }
    
    public var aniamtor: AlertbleAnimator = AlertAnimator()
    
    public var layoutGuide = LayoutGuide(width: .flexible, height: .flexible)
    
    public var layout: AlertableLayout = AlertLayout()
    
    public private(set) var isActive: Bool = false
        
    private lazy var alertContainerController = AlertContainerController(alert: self)
    
    private let backdropView = DimmingKnockoutBackdropView()
    
    private let dimmingView = DimmingView()
    
    private let tapTarget = TapTarget()
    
    private let keyboardEventMonitor = KeyboardEventMonitor()
    
    private var lifecycleListeners: [LifecycleListener] = []
    
    private var orientationChangeToken: NotificationToken?
    
    private var window: AlertWindow?
    
    #if DEBUG
    deinit {
        print("deinit \(self)")
    }
    #endif
    
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
                updateLayout()
            })
    }
    
    private func observeKeyboardEvent() {
        keyboardEventMonitor.keyboardWillShow = { [weak self] info in
            guard let self, isActive else { return }
            // TODO: 处理键盘事件
        }
        keyboardEventMonitor.keyboardWillHidden = { [weak self] info in
            guard let self, isActive else { return }
            // TODO: 处理键盘事件
        }
    }
    
    private func configBackdrop() {
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
    
    public func addListener(_ listener: LifecycleListener) {
        lifecycleListeners.append(listener)
    }
    
    public func show(in hosting: AlertHosting? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard !isActive else { return }
        observeKeyboardEvent()
        observeDeviceRotation()
        configBackdrop()
        configDimming()
        configContainer()
        showAlert(in: hosting)
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard isActive else { return }
        dismissAlert(completion: completion)
    }
    
    public func dismiss() async {
        await withUnsafeContinuation({ continuation in
            dismiss { continuation.resume() }
        })
    }
    
    open func willShow() { }
    
    open func didShow() { }
    
    open func willDismiss() { }
    
    open func didDismiss() { }
    
    open func willLayoutContainer() { }
    
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
    
    private func configDimming() {
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
    
    private func configContainer() {
        backdropView.addSubview(alertContainerController.view)
        NSLayoutConstraint.activate([
            alertContainerController.view.widthAnchor.constraint(lessThanOrEqualTo: backdropView.widthAnchor),
            alertContainerController.view.heightAnchor.constraint(lessThanOrEqualTo: backdropView.heightAnchor)
        ])
        
        // Add view or viewController
        if let view = alertContent as? UIView {
            alertContainerController.view.addSubview(view)
            layoutFill(view)
        } else if let viewController = alertContent as? UIViewController {
            viewController.willMove(toParent: alertContainerController)
            alertContainerController.addChild(viewController)
            alertContainerController.view.addSubview(viewController.view)
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
        UIView.performWithoutAnimation { [self] in
            layout.updateLayout(context: layoutContext, layoutGuide: layoutGuide)
        }
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
        aniamtor.show(context: layoutContext) { [weak self] in
            self?.didShow()
            self?.lifecycleListeners.forEach { $0.didShow() }
            self?.alertContainerController.view.isUserInteractionEnabled = true
            self?.tapTarget.tapGestureRecognizer.isEnabled = true
            if let viewController = self?.alertContent as? UIViewController {
                viewController.endAppearanceTransition()
            }
        }
    }
    
    private func _showAlert(in view: UIView) {
        backdropView.frame = view.bounds
        view.addSubview(backdropView)
        updateLayout()
        performShowWithAnimation()
    }
    
    private func _showAlert(in viewController: UIViewController) {
        backdropView.frame = viewController.view.bounds
        viewController.view.addSubview(backdropView)
        updateLayout()
        performShowWithAnimation()
    }
    
    private func showAlert(in parent: AlertHosting?) {
        if let view = parent as? UIView {
            view.attach(alert: self)
            _showAlert(in: view)
        } else if let viewController = parent as? UIViewController {
            viewController.view.attach(alert: self)
            _showAlert(in: viewController)
        } else {
            setupWindow()
            if let viewController = window?.rootViewController {
                window?.attach(alert: self)
                _showAlert(in: viewController)
            }
        }
    }
}

extension Alert {
    
    private func dismissAlert(completion: (() -> Void)?) {
        isActive = false
        willDismiss()
        lifecycleListeners.forEach { $0.willDismiss() }
        if let viewController = alertContent as? UIViewController {
            viewController.beginAppearanceTransition(false, animated: true)
        }
        
        alertContainerController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        aniamtor.dismiss(context: layoutContext) { [weak self] in
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
        guard let interfaceOrientation = windowScene?.interfaceOrientation else {
            return UIApplication.shared.statusBarOrientation
        }
        return interfaceOrientation
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
