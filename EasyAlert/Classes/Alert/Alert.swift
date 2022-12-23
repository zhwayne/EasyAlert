//
//  Alert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

/// The base alert.
open class Alert: Alertble {
    
    public let customizable: AlertCustomizable
    
    /// A Provider that interacts with the backdrop
    public var backdropProvider: BackdropProvider = DefaultBackdropProvider()
    
    public var transitionCoordinator: TransitionCoordinator = AlertTransitionCoordinator()
    
    public var isShowing: Bool { backdropView.superview != nil }
    
    private let alertViewController = AlertViewController()
                
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
        orientationChangeToken = NotificationCenter.default.observe(name: name, object: nil, queue: nil, using: { [weak self] _ in
            self?.layoutIfNeeded()
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
                let point = view.convert(point, to: alertViewController.view)
                return !alertViewController.view.bounds.contains(point)
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
            return !alertViewController.view.frame.contains(point)
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

    open func willShow() { }
    
    open func didShow() { }
    
    open func willDismiss() { }
    
    open func didDismiss() { }
    
    open func willLayoutContainer() { }
    
    open func didLayoutContainer() { }
    
    public func addCallback(_ callback: LiftcycleCallback) {
        callbacks.append(callback)
    }
    
    public func show(in container: AlertContainerable? = nil) {
        
        func _show(in view: UIView? = nil) {
            Dispatch.dispatchPrecondition(condition: .onQueue(.main))
            guard !isShowing else { return }
            let parent = findParentView(view)
            configDimming()
            configContainer()
            showAlert(in: parent)
        }
        
        if let container = container as? UIView {
            _show(in: container)
        } else if let container = container as? UIViewController {
            _show(in: container.view)
        } else {
            _show(in: nil)
        }
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard canDismiss() else {
            return
        }
        
        if let viewController = customizable as? UIViewController {
            viewController.beginAppearanceTransition(false, animated: true)
        }
        willDismiss()
        callbacks.forEach { $0.willDismiss?() }
        
        alertViewController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        transitionCoordinator.dismiss(context: transitioningContext) { [weak self] in
            self?.didDismiss()
            self?.callbacks.forEach { $0.didDismiss?() }
            if let viewController = self?.customizable as? UIViewController {
                viewController.endAppearanceTransition()
            }
            completion?()
            self?.windup()
            self?.alertViewController.view.isUserInteractionEnabled = true
            self?.tapTarget.tapGestureRecognizer.isEnabled = true
        }
    }
    
    @available(iOS 13.0, *)
    public func dismissAsync() async {
        await withUnsafeContinuation({ continuation in
            dismiss { continuation.resume() }
        })
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
    
    private var transitioningContext: TransitionCoordinatorContext {
        TransitionCoordinatorContext(
            container: alertViewController.view,
            backdropView: backdropView,
            dimmingView: dimmingView,
            interfaceOrientation: interfaceOrientation
        )
    }
    
    private func findParentView(_ view: UIView?) -> UIView {
        if let view = view { return view } else {
//            if #available(iOS 13.0, *) {
//                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//                    return windowScene.windows.first { $0.isKeyWindow }
//                } else {
//                    return nil
//                }
//            } else {
//                return UIApplication.shared.keyWindow
//            }
            if window == nil {
                window = AlertWindow(frame: UIScreen.main.bounds)
            }
            window?.windowLevel = .alert
            window?.makeKeyAndVisible()
            return window!
        }
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
        backdropView.addSubview(alertViewController.view)
        
        // Add view or viewController
        if let view = customizable as? UIView {
            alertViewController.view.addSubview(view)
            layoutFill(view)
        } else if let viewController = customizable as? UIViewController {
            viewController.willMove(toParent: alertViewController)
            alertViewController.addChild(viewController)
            alertViewController.view.addSubview(viewController.view)
            viewController.didMove(toParent: alertViewController)
            layoutFill(viewController.view)
        }
        layoutIfNeeded()
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
    
    private func layoutIfNeeded() {
        backdropView.layoutIfNeeded()
        willLayoutContainer()
        transitionCoordinator.update(context: transitioningContext)
        didLayoutContainer()
        alertViewController.view.layoutIfNeeded()
    }
    
    private func showAlert(in parent: UIView) {
        // Set associated object.
        alertViewController.weakAlert = self
        parent.attach(alert: self)
        
        //
        backdropView.frame = parent.bounds
        parent.addSubview(backdropView)
        backdropView.layoutIfNeeded()

        if let viewController = customizable as? UIViewController {
            viewController.beginAppearanceTransition(true, animated: true)
        }
        willShow()
        callbacks.forEach { $0.willShow?() }
        
        alertViewController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        transitionCoordinator.show(context: transitioningContext) { [weak self] in
            self?.didShow()
            self?.callbacks.forEach { $0.didShow?() }
            self?.alertViewController.view.isUserInteractionEnabled = true
            self?.tapTarget.tapGestureRecognizer.isEnabled = true
            if let viewController = self?.customizable as? UIViewController {
                viewController.endAppearanceTransition()
            }
        }
    }
    
    private func windup() {
        alertViewController.weakAlert = nil
        
        if let view = customizable as? UIView {
            view.removeFromSuperview()
        } else if let viewController = customizable as? UIViewController {
            viewController.removeFromParent()
            viewController.view.removeFromSuperview()
            viewController.didMove(toParent: nil)
        }
        if let parent = backdropView.superview {
            parent.detach(alert: self)
            alertViewController.view.removeFromSuperview()
            backdropView.removeFromSuperview()
        }
        window?.resignKey()
        window?.isHidden = true
        window = nil
    }
}
