//
//  Alert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

open class Alert: Alertble {
    
    public typealias CustomizedView = UIView & AlertCustomizable
    
    /// The view that can be customized according to your ideas.
    public let customView: CustomizedView
    
    public var backgroundProvider: BackgroundProvider = DefaultBackgroundProvider()
    
    private let alertViewController = AlertViewController()
    
    private var view: UIView { alertViewController.view }
    
    public var transitionCoordinator: TransitionCoordinator = AlertTransitionCoordinator()
        
    private let backgroundView = DimmingKnockoutBackdropView()

    private let dimmingView = DimmingView()
        
    private let tapTarget = TapTarget()
        
    public private(set) var isShowing = false
    
    private var callbacks: [LiftcycleCallback] = []
    
    private var orientationChangeToken: NotificationToken?
            
    public init(customView: CustomizedView) {
        self.customView = customView
        backgroundView.frame = UIScreen.main.bounds
        backgroundView.willRemoveFromSuperviewObserver = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss()
            }
        }
        backgroundView.addGestureRecognizer(tapTarget.tapGestureRecognizer)
        
        tapTarget.gestureRecognizerShouldBeginBlock = { [unowned self] gestureRecognizer in
            guard let backgroundView = gestureRecognizer.view else { return false }
            let point = gestureRecognizer.location(in: backgroundView)
            return !view.frame.contains(point)
        }
        
        tapTarget.tapHandler = { [unowned self] in
            backgroundView.endEditing(false)
            if backgroundProvider.allowDismissWhenBackgroundTouch {
                DispatchQueue.main.async {
                    self.dismiss()
                }
            }
        }
        
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        let name = UIDevice.orientationDidChangeNotification
        orientationChangeToken = NotificationCenter.default.observe(name: name, object: nil, queue: nil, using: { [weak self] _ in
            self?.layoutIfNeeded()
        })
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
    
    @MainActor public func show(in view: UIView? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard let parent = findParentView(view),
              canShow(in: parent) else {
            return
        }
        defer { isShowing = true }
        configDimming()
        configContainer()
        showAlert(in: parent)
    }
    
    @MainActor public func dismiss(completion: (() -> Void)? = nil) {
        Dispatch.dispatchPrecondition(condition: .onQueue(.main))
        guard canDismiss() else {
            return
        }
        
        willDismiss()
        callbacks.forEach { $0.willDismiss?() }
        
        transitionCoordinator.dismiss(context: transitioningContext) { [weak self] in
            self?.didDismiss()
            self?.callbacks.forEach { $0.didDismiss?() }
            completion?()
            self?.windup()
        }
    }
    
    @available(iOS 13.0, *)
    @MainActor public func dismiss() async {
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
            container: view,
            backgroundView: backgroundView,
            dimmingView: dimmingView,
            interfaceOrientation: interfaceOrientation,
            frame: backgroundView.bounds
        )
    }
    
    private func findParentView(_ view: UIView?) -> UIView? {
        if let view = view { return view } else {
            if #available(iOS 13.0, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    return windowScene.windows.first { $0.isKeyWindow }
                } else {
                    return nil
                }
            } else {
                return UIApplication.shared.keyWindow
            }
        }
    }
    
    private func canShow(in view: UIView) -> Bool {
        return !isShowing && !view.subviews.contains(backgroundView)
    }
    
    private func canDismiss() -> Bool {
        return isShowing || backgroundView.superview != nil
    }
    
    private func configDimming() {
        switch backgroundProvider.dimming {
        case .color(let color): dimmingView.backgroundColor = color
        case .view(let view):   dimmingView.contentView = view
        }
        dimmingView.isUserInteractionEnabled = false
        dimmingView.frame = backgroundView.bounds
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.insertSubview(dimmingView, at: 0)
    }
    
    private func configContainer() {
        backgroundView.addSubview(view)
        view.addSubview(customView)
        customView.frame = view.bounds
        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        layoutIfNeeded()
    }
    
    private func layoutIfNeeded() {
        backgroundView.layoutIfNeeded()
        willLayoutContainer()
        transitionCoordinator.update(context: transitioningContext)
        didLayoutContainer()
        view.layoutIfNeeded()
    }
    
    private func showAlert(in parent: UIView) {
        parent.attach(alert: self)
        backgroundView.alert = self
        backgroundView.frame = parent.bounds
        parent.addSubview(backgroundView)
        backgroundView.layoutIfNeeded()

        willShow()
        callbacks.forEach { $0.willShow?() }
        
        transitionCoordinator.show(context: transitioningContext) { [weak self] in
            self?.didShow()
            self?.callbacks.forEach { $0.didShow?() }
        }
    }
    
    private func windup() {
        defer {
            if let parent = backgroundView.superview {
                parent.detach(alert: self)
                backgroundView.removeFromSuperview()
            }
        }
        backgroundView.alert = nil
        isShowing = false
    }
}
