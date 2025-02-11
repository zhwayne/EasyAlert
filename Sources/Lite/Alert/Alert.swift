//
//  Alert.swift
//  EasyAlert
//
//  Created by iya on 2021/7/27.
//

import UIKit

/// The base alert.
@MainActor open class Alert: Alertble {
    
    public let alertContent: AlertCustomizable
    
    /// A Provider that interacts with the backdrop
    public var backdropProvider: BackdropProvider = DefaultBackdropProvider() {
        didSet { configDimming() }
    }
    
    public var transitionAniamtor: TransitionAnimator = AlertTransitionAnimator()
    
    var layoutModifier: LayoutModifier = AlertLayoutModifier()
    
    public var isShowing: Bool { backdropView.superview != nil }
    
    public var layoutGuide = LayoutGuide()
    
    private let alertContainerController = AlertContainerController()
    
    private let backdropView = DimmingKnockoutBackdropView()
    
    private let dimmingView = DimmingView()
    
    private let tapTarget = TapTarget()
    
    private var callbacks: [LiftcycleCallback] = []
    
    private var orientationChangeToken: NotificationToken?
    
    private var window: AlertWindow?
    
    #if DEBUG
    deinit {
        print("deinit \(self)")
    }
    #endif
    
    public init(content: AlertCustomizable) {
        guard content is UIView || content is UIViewController else {
            fatalError("Unsupported type: \(type(of: content))")
        }
        self.alertContent = content
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
        backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backdropView.addGestureRecognizer(tapTarget.tapGestureRecognizer)
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
        window?.windowLevel = .alert - 1
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
        backdropView.addSubview(alertContainerController.view)
        
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
    
    func updateLayout() {
        willLayoutContainer()
        UIView.performWithoutAnimation { [self] in
            layoutModifier.update(context: layoutContext, layoutGuide: layoutGuide)
            backdropView.setNeedsLayout()
            backdropView.layoutIfNeeded()
        }
        didLayoutContainer()
    }
    
    private func performShowWithAnimation() {
        if let viewController = alertContent as? UIViewController {
            viewController.beginAppearanceTransition(true, animated: true)
        }
        willShow()
        callbacks.forEach { $0.willShow?() }
        
        alertContainerController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        transitionAniamtor.show(context: layoutContext) { [weak self] in
            self?.didShow()
            self?.callbacks.forEach { $0.didShow?() }
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
    
    private func showAlert(in parent: AlertContainer?) {
        // Set associated object.
        alertContainerController.weakAlert = self
        
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
        if let viewController = alertContent as? UIViewController {
            viewController.beginAppearanceTransition(false, animated: true)
        }
        willDismiss()
        callbacks.forEach { $0.willDismiss?() }
        
        alertContainerController.view.isUserInteractionEnabled = false
        tapTarget.tapGestureRecognizer.isEnabled = false
        transitionAniamtor.dismiss(context: layoutContext) { [weak self] in
            self?.didDismiss()
            self?.callbacks.forEach { $0.didDismiss?() }
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
        alertContainerController.weakAlert = nil
        
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
    
    private var layoutContext: LayoutContext {
        LayoutContext(
            containerView: backdropView,
            dimmingView: dimmingView,
            presentedView: alertContainerController.view,
            interfaceOrientation: interfaceOrientation
        )
    }
}
