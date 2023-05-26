//
//  Alert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

/// The base alert.
@MainActor open class Alert: Alertble {
    
    public let customizable: AlertCustomizable
    
    /// A Provider that interacts with the backdrop
    public var backdropProvider: BackdropProvider = DefaultBackdropProvider() {
        didSet { configDimming() }
    }
    
    public var transitionAniamtor: TransitionAnimator = AlertTransitionAnimator()
    
    public var isShowing: Bool { backdropView.superview != nil }
    
    public var layoutGuide = LayoutGuide(width: .fixed(270))
    
    private let alertContainerViewController = AlertContainerViewController()
    
    private let backdropView = DimmingKnockoutBackdropView()
    
    private let dimmingView = DimmingView()
    
    private let tapTarget = TapTarget()
    
    private var callbacks: [LiftcycleCallback] = []
    
    private var orientationChangeToken: NotificationToken?
    
    private var window: AlertWindow?
    
    public init<T: AlertCustomizable>(customizable: T) {
        guard customizable is UIView || customizable is UIViewController else {
            fatalError()
        }
        self.customizable = customizable
        observeDeviceRotation()
        configBackdrop()
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
        backdropView.addGestureRecognizer(tapTarget.tapGestureRecognizer)
        backdropView.frame = UIScreen.main.bounds
        backdropView.hitTest = { [unowned self] view, point in
            switch backdropProvider.penetrationScope {
            case .none: return false
            case .all: return true
            case .dimming:
                let point = view.convert(point, to: alertContainerViewController.view)
                return !alertContainerViewController.view.bounds.contains(point)
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
            return !alertContainerViewController.view.frame.contains(point)
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
    
    public func show(in container: AlertContainerable? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard !isShowing else { return }
        
        configDimming()
        configContainer()
        showAlert(in: container)
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard canDismiss() else { return }
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
    
    private func canDismiss() -> Bool {
        return isShowing || backdropView.superview != nil
    }
    
    private func configDimming() {
        switch backdropProvider.dimming {
        case let .color(color): dimmingView.backgroundColor = color
        case let .view(view):   dimmingView.contentView = view
        case let .blur(style, level):
            let blurView = BlurEffectView(effect: UIBlurEffect(style: style), intensity: level)
            dimmingView.contentView = blurView
        }
        dimmingView.isUserInteractionEnabled = false
        dimmingView.frame = backdropView.bounds
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backdropView.insertSubview(dimmingView, at: 0)
    }
    
    private func configContainer() {
        backdropView.addSubview(alertContainerViewController.view)
        
        // Add view or viewController
        if let view = customizable as? UIView {
            alertContainerViewController.view.addSubview(view)
            layoutFill(view)
        } else if let viewController = customizable as? UIViewController {
            viewController.willMove(toParent: alertContainerViewController)
            alertContainerViewController.addChild(viewController)
            alertContainerViewController.view.addSubview(viewController.view)
            viewController.didMove(toParent: alertContainerViewController)
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
    
    func updateLayout() {
        willLayoutContainer()
        transitionAniamtor.update(context: transitioningContext, layoutGuide: layoutGuide)
        backdropView.setNeedsLayout()
        backdropView.layoutIfNeeded()
        didLayoutContainer()
    }
    
    private func performShowWithAnimation() {
        if let viewController = customizable as? UIViewController {
            viewController.beginAppearanceTransition(true, animated: true)
        }
        willShow()
        callbacks.forEach { $0.willShow?() }
        
        alertContainerViewController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        transitionAniamtor.show(context: transitioningContext) { [weak self] in
            self?.didShow()
            self?.callbacks.forEach { $0.didShow?() }
            self?.alertContainerViewController.view.isUserInteractionEnabled = true
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
    
    private func showAlert(in parent: AlertContainerable?) {
        // Set associated object.
        alertContainerViewController.weakAlert = self
        
        if let view = parent as? UIView {
            view.attach(alert: self)
            _showAlert(in: view)
        } else if let viewController = parent as? UIViewController {
            viewController.attach(alert: self)
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
        willDismiss()
        callbacks.forEach { $0.willDismiss?() }
        
        alertContainerViewController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        transitionAniamtor.dismiss(context: transitioningContext) { [weak self] in
            self?.didDismiss()
            self?.callbacks.forEach { $0.didDismiss?() }
            if let viewController = self?.customizable as? UIViewController {
                viewController.endAppearanceTransition()
            }
            completion?()
            self?.clean()
            self?.alertContainerViewController.view.isUserInteractionEnabled = true
            self?.tapTarget.tapGestureRecognizer.isEnabled = true
        }
    }
    
    private func clean() {
        alertContainerViewController.weakAlert = nil
        
        if let view = customizable as? UIView {
            view.removeFromSuperview()
        } else if let viewController = customizable as? UIViewController {
            viewController.removeFromParent()
            viewController.view.removeFromSuperview()
            viewController.didMove(toParent: nil)
        }
        if let parent = backdropView.superview {
            parent.detach(alert: self)
            alertContainerViewController.view.removeFromSuperview()
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
            container: alertContainerViewController.view,
            backdropView: backdropView,
            dimmingView: dimmingView,
            interfaceOrientation: interfaceOrientation
        )
    }
}
