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
        
    private let backdropView = DimmingKnockoutBackdropView()

    private let dimmingView = DimmingView()
        
    private let tapTarget = TapTarget()
        
    public private(set) var isShowing = false
    
    private var callbacks: [LiftcycleCallback] = []
    
    private var orientationChangeToken: NotificationToken?
    
    var isUserInteractionEnabled: Bool {
        get { backdropView.isUserInteractionEnabled }
        set { backdropView.isUserInteractionEnabled = newValue }
    }
            
    public init(customView: CustomizedView) {
        self.customView = customView
        backdropView.frame = UIScreen.main.bounds
        backdropView.willRemoveFromSuperviewObserver = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss()
            }
        }
        backdropView.addGestureRecognizer(tapTarget.tapGestureRecognizer)
        
        tapTarget.gestureRecognizerShouldBeginBlock = { [unowned self] gestureRecognizer in
            guard let backgroundView = gestureRecognizer.view else { return false }
            let point = gestureRecognizer.location(in: backgroundView)
            return !view.frame.contains(point)
        }
        
        tapTarget.tapHandler = { [unowned self] in
            backdropView.endEditing(false)
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
    
    public func show(in container: AlertContainerable? = nil) {
        
        func _show(in view: UIView? = nil) {
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
        
        willDismiss()
        callbacks.forEach { $0.willDismiss?() }
        
        let parent = backdropView.superview!
        let oldParentUserInteractionEnabled = parent.isUserInteractionEnabled
        if isUserInteractionEnabled {
            parent.isUserInteractionEnabled = false
        }
        transitionCoordinator.dismiss(context: transitioningContext) { [weak self] in
            self?.didDismiss()
            self?.callbacks.forEach { $0.didDismiss?() }
            completion?()
            self?.windup()
            parent.isUserInteractionEnabled = oldParentUserInteractionEnabled
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
            container: view,
            backdropView: backdropView,
            dimmingView: dimmingView,
            interfaceOrientation: interfaceOrientation
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
        return !isShowing && !view.subviews.contains(backdropView)
    }
    
    private func canDismiss() -> Bool {
        return isShowing || backdropView.superview != nil
    }
    
    private func configDimming() {
        switch backgroundProvider.dimming {
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
        backdropView.addSubview(view)
        view.addSubview(customView)
        customView.frame = view.bounds
        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        layoutIfNeeded()
    }
    
    private func layoutIfNeeded() {
        backdropView.layoutIfNeeded()
        willLayoutContainer()
        transitionCoordinator.update(context: transitioningContext)
        didLayoutContainer()
        view.layoutIfNeeded()
    }
    
    private func showAlert(in parent: UIView) {
        parent.attach(alert: self)
        backdropView.alert = self
        backdropView.frame = parent.bounds
        parent.addSubview(backdropView)
        backdropView.layoutIfNeeded()

        willShow()
        callbacks.forEach { $0.willShow?() }
        
        let oldParentUserInteractionEnabled = parent.isUserInteractionEnabled
        if !isUserInteractionEnabled {
            parent.isUserInteractionEnabled = false
        }
        transitionCoordinator.show(context: transitioningContext) { [weak self] in
            self?.didShow()
            self?.callbacks.forEach { $0.didShow?() }
            parent.isUserInteractionEnabled = oldParentUserInteractionEnabled
        }
    }
    
    private func windup() {
        defer {
            if let parent = backdropView.superview {
                parent.detach(alert: self)
                backdropView.removeFromSuperview()
            }
        }
        backdropView.alert = nil
        isShowing = false
    }
}
