//
//  Alert.swift
//  EasyAlert
//
//  Created by iya on 2021/7/27.
//

import UIKit

/// The base alert.
@MainActor open class Alert: Alertable {
    
    public let customizable: AlertCustomizable
    
    /// A Provider that interacts with the backdrop
    public var backdropProvider: BackdropProvider = DefaultBackdropProvider() {
        didSet {
            if let dimmingView {
                dimmingView.contentView = backdropProvider.dimming.makeUIView()
            }
        }
    }

    public var layoutGuide = LayoutGuide() {
        didSet {
            if backdropView != nil {
                updateLayout()
            }
        }
    }
    
    public var transitionAniamtor: TransitionAnimator = AlertTransitionAnimator()
    
    public private(set) var isActive: Bool = false
    
    private lazy var alertContainerController = AlertContainerController(alert: self)
    
    private var backdropView: DimmingKnockoutBackdropView!
    
    private var dimmingView: DimmingView!
    
    private let tapTarget = TapTarget()
    
    private var callbacks: [LiftcycleCallback] = []
    
    private var orientationChangeToken: NotificationToken?
    
    private var window: AlertWindow?
    
    #if DEBUG
    deinit {
        NSLog("%@", "\(self) deinitialized.")
    }
    #endif
    
    public init(customizable: AlertCustomizable) {
        guard customizable is UIView || customizable is UIViewController else {
            fatalError("Unsupported type: \(type(of: customizable))")
        }
        self.customizable = customizable
    }
    
    private func observeDeviceRotation() {
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        let name = UIDevice.orientationDidChangeNotification
        orientationChangeToken = NotificationCenter.default.observe(name: name, object: nil, queue: nil, using: { [weak self] note in
            self?.updateLayout()
        })
    }
    
    private func configBackdrop() {
        guard backdropView == nil else { return }
        
        backdropView = DimmingKnockoutBackdropView()
        backdropView.addGestureRecognizer(tapTarget.tapGestureRecognizer)
        backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backdropView.hitTest = { [unowned self] view, point in
            switch backdropProvider.penetrationScope {
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
            if backdropProvider.allowDismissWhenBackgroundTouch {
                DispatchQueue.main.async {
                    self.dismiss()
                }
            }
        }
    }
    
    public func addCallback(_ callback: LiftcycleCallback) {
        callbacks.append(callback)
    }
    
    public func show(in container: AlertContainer? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard !isActive else { return }
        
        observeDeviceRotation()
        configBackdrop()
        configDimming()
        configContainer()
        showAlert(in: container)
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard isActive else { return }
        dismissAlert(completion: completion)
    }
    
    @available(iOS 13.0, *)
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
        if window == nil {
            if #available(iOS 13.0, *) {
                for scene in UIApplication.shared.connectedScenes where scene is UIWindowScene {
                    let windowScene = scene as! UIWindowScene
                    window = AlertWindow(windowScene: windowScene)
                    break
                }
                if window == nil {
                    // Fallback
                    window = AlertWindow(frame: UIScreen.main.bounds)
                }
            } else {
                // Fallback on earlier versions
                window = AlertWindow(frame: UIScreen.main.bounds)
            }
        }
        window?.rootViewController = UIViewController()
        window?.backgroundColor = .clear
        window?.windowLevel = .alert
        window?.makeKeyAndVisible()
    }
    
    private func configDimming() {
        guard dimmingView == nil else { return }
        dimmingView = DimmingView()
        dimmingView.contentView = backdropProvider.dimming.makeUIView()
        dimmingView.isUserInteractionEnabled = false
        backdropView.insertSubview(dimmingView, at: 0)
        layoutFill(dimmingView)
    }
    
    private func configContainer() {
        backdropView.addSubview(alertContainerController.view)
        
        // Add view or viewController
        if let view = customizable as? UIView {
            alertContainerController.view.addSubview(view)
            layoutFill(view)
        } else if let viewController = customizable as? UIViewController {
            viewController.willMove(toParent: alertContainerController)
            alertContainerController.addChild(viewController)
            alertContainerController.view.addSubview(viewController.view)
            viewController.didMove(toParent: alertContainerController)
            layoutFill(viewController.view)
        }
    }
    
    private func layoutFill(_ view: UIView) {
        guard let superview = view.superview else { fatalError() }
        view.frame = superview.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func updateLayout() {
        willLayoutContainer()
        UIView.performWithoutAnimation { [self] in
            transitionAniamtor.update(context: transitioningContext, layoutGuide: layoutGuide)
            backdropView.setNeedsLayout()
            backdropView.layoutIfNeeded()
        }
        didLayoutContainer()
    }
    
    private func performShowWithAnimation() {
        if let viewController = customizable as? UIViewController {
            viewController.beginAppearanceTransition(true, animated: true)
        }
        isActive = true
        willShow()
        callbacks.forEach { $0.willShow?() }
        
        alertContainerController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        transitionAniamtor.show(context: transitioningContext) { [weak self] in
            self?.didShow()
            self?.callbacks.forEach { $0.didShow?() }
            self?.alertContainerController.view.isUserInteractionEnabled = true
            self?.tapTarget.tapGestureRecognizer.isEnabled = true
            if let viewController = self?.customizable as? UIViewController {
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
    
    private func showAlert(in parent: AlertContainer?) {        
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
        if let viewController = customizable as? UIViewController {
            viewController.beginAppearanceTransition(false, animated: true)
        }
        isActive = false
        willDismiss()
        callbacks.forEach { $0.willDismiss?() }
        
        alertContainerController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        transitionAniamtor.dismiss(context: transitioningContext) { [weak self] in
            self?.didDismiss()
            self?.callbacks.forEach { $0.didDismiss?() }
            if let viewController = self?.customizable as? UIViewController {
                viewController.endAppearanceTransition()
            }
            completion?()
            self?.clean()
            self?.alertContainerController.view.isUserInteractionEnabled = true
            self?.tapTarget.tapGestureRecognizer.isEnabled = true
        }
    }
    
    private func clean() {
        if let view = customizable as? UIView {
            view.removeFromSuperview()
        } else if let viewController = customizable as? UIViewController {
            viewController.removeFromParent()
            viewController.view.removeFromSuperview()
            viewController.didMove(toParent: nil)
        }
        if let parent = backdropView.superview {
            parent.detach(alert: self)
            alertContainerController.view.removeFromSuperview()
            backdropView.removeFromSuperview()
        }
        window?.resignKey()
        window?.isHidden = true
        window = nil
    }
}

extension Alert {
    
    private var interfaceOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene
            guard let interfaceOrientation = windowScene?.interfaceOrientation else {
                return UIApplication.shared.statusBarOrientation
            }
            return interfaceOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    private var transitioningContext: TransitionContext {
        TransitionContext(
            backdropView: backdropView,
            dimmingView: dimmingView,
            container: alertContainerController.view,
            interfaceOrientation: interfaceOrientation
        )
    }
}
