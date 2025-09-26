//
//  LifecycleListener.swift
//  EasyAlert
//
//  Created by iya on 2022/5/28.
//

import Foundation

@MainActor public protocol LifecycleListener {

    func willShow()

    func didShow()

    func willDismiss()

    func didDismiss()
}

extension LifecycleListener {

    public func willShow() { }

    public func didShow() { }

    public func willDismiss() { }

    public func didDismiss() { }
}

public struct LifecycleCallback: LifecycleListener {

    public typealias LifecycleHandler = () -> Void

    let willShowHandler: LifecycleHandler?

    let didShowHandler: LifecycleHandler?

    let willDismissHandler: LifecycleHandler?

    let didDismissHandler: LifecycleHandler?

    public init(willShow: LifecycleHandler? = nil,
                didShow: LifecycleHandler? = nil,
                willDismiss: LifecycleHandler? = nil,
                didDismiss: LifecycleHandler? = nil) {
        self.willShowHandler = willShow
        self.didShowHandler = didShow
        self.willDismissHandler = willDismiss
        self.didDismissHandler = didDismiss
    }

    public func willShow() {
        willShowHandler?()
    }

    public func didShow() {
        didShowHandler?()
    }

    public func willDismiss() {
        willDismissHandler?()
    }

    public func didDismiss() {
        didDismissHandler?()
    }
}
