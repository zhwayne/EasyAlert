//
//  Alert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit
import SnapKit

open class Alert: Alertble {
    
    public typealias CustomizedView = UIView & AlertCustomable
    
    /// The view that can be customized according to your ideas.
    public let customView: CustomizedView
    
    public var backgroundProvider: BackgroundProvider = DefaultBackgroundProvider()
    
    let containerView: UIView = UIView()
    
    public var layout: ContainerLayout? = AlertLayout()
    
    public var animator: Animator = AlertAnimator()
    
    private let backgroundView = TransitionView()

    private var dimmingView = UIView()
        
    private let tapTarget = TapTarget()
        
    private(set) var isShowing = false
    
    private var notificationToken: NotificationToken?
    
    public init(customView: CustomizedView) {
        self.customView = customView
        
        backgroundView.willRemoveFromSuperviewObserver = { [weak self] in
            if let alert = self?.backgroundView.alert {
                alert.dismiss(completion: nil)
            }
        }
        backgroundView.addGestureRecognizer(tapTarget.tapGestureRecognizer)
        
        tapTarget.gestureRecognizerShouldBeginBlock = { [unowned self] gestureRecognizer in
            guard let backgroundView = gestureRecognizer.view else { return false }
            let point = gestureRecognizer.location(in: backgroundView)
            return !containerView.frame.contains(point)
        }
        
        tapTarget.tapHandler = { [unowned self] in
            backgroundView.endEditing(false)
            if backgroundProvider.allowDismissWhenBackgroundTouch {
                dismiss()
            }
        }
        
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        let name = UIDevice.orientationDidChangeNotification
        notificationToken = NotificationCenter.default.observe(name: name, object: nil, queue: nil, using: { [weak self] _ in
            self?.layoutIfNeeded()
        })
    }
    
    open func willShow() { }
    
    open func didShow() { }
    
    open func willDismiss() { }
    
    open func didDismiss() { }
    
    open func willLayoutContainer() { }
    
    open func didLayoutContainer() { }
    
    open func show(in view: UIView?) {
        assert(Thread.isMainThread && OperationQueue.current == OperationQueue.main)
        guard let parent = findParentView(view),
              canShow(in: parent) else {
            return
        }
        defer { isShowing = true }
        configDimming()
        configContainer()
        showAlert(in: parent)
    }
    
    open func dismiss(completion: (() -> Void)? = nil) {
        assert(Thread.isMainThread && OperationQueue.current == OperationQueue.main)
        guard canDismiss() else {
            return
        }
        let context = AnimatorContext(
            container: containerView,
            dimmingView: dimmingView
        )
        willDismiss()
        animator.dismiss(context: context, completion: { [weak self] in
            self?.didDismiss()
            completion?()
            self?.windup()
        })
    }
}

extension Alert {
    
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
        case .view(let view):   dimmingView = view
        }
        dimmingView.isUserInteractionEnabled = false
        dimmingView.frame = backgroundView.bounds
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.insertSubview(dimmingView, at: 0)
    }
    
    private func layoutIfNeeded() {
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene else { return }
            willLayoutContainer()
            layout?.updateLayout(container: containerView, content: customView, interfaceOrientation: windowScene.interfaceOrientation)
        } else {
            // Fallback on earlier versions
            willLayoutContainer()
            layout?.updateLayout(container: containerView, content: customView, interfaceOrientation: UIApplication.shared.statusBarOrientation)
        }
        didLayoutContainer()
        containerView.layoutIfNeeded()
    }
    
    private func configContainer() {
        backgroundView.addSubview(containerView)
        layoutIfNeeded()
    }
    
    private func showAlert(in parent: UIView) {
        objc_setAssociatedObject(parent, &AssociatedKey.alert, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        backgroundView.alert = self
        backgroundView.frame = parent.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parent.addSubview(backgroundView)
        backgroundView.layoutIfNeeded()
        
        let context = AnimatorContext(
            container: containerView,
            dimmingView: dimmingView
        )
        willShow()
        animator.show(context: context) { [weak self] in
            self?.didShow()
        }
    }
    
    private func windup() {
        defer {
            if let parent = backgroundView.superview {
                objc_setAssociatedObject(parent, &AssociatedKey.alert, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                backgroundView.removeFromSuperview()
            }
        }
        backgroundView.alert = nil
        isShowing = false
    }
}

public extension Alert {
    
    private struct AssociatedKey {
        static var alert = "alert"
    }
}
