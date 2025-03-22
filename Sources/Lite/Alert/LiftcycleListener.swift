//
//  LiftcycleListener.swift
//  EasyAlert
//
//  Created by iya on 2022/5/28.
//

import Foundation

@MainActor public protocol LiftcycleListener {
    
    func willShow()
    
    func didShow()
    
    func willDismiss()
    
    func didDismiss()
}

extension LiftcycleListener {
    
    public func willShow() { }
    
    public func didShow() { }
    
    public func willDismiss() { }
    
    public func didDismiss() { }
}

public struct LiftcycleCallback: LiftcycleListener {
    
    public typealias Handler = () -> Void
    
    let willShowHandler: Handler?
    
    let didShowHandler: Handler?
    
    let willDismissHandler: Handler?
    
    let didDismissHandler: Handler?
    
    public init(willShow: Handler? = nil,
                didShow: Handler? = nil,
                willDismiss: Handler? = nil,
                didDismiss: Handler? = nil) {
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
