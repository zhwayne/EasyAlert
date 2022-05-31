//
//  AlertCallback.swift
//  EasyAlert
//
//  Created by iya on 2022/5/28.
//

import Foundation

public struct LiftcycleCallback {
    
    public typealias Handler = () -> Void
    
    var willShow: Handler?
    
    var didShow: Handler?
    
    var willDismiss: Handler?
    
    var didDismiss: Handler?
    
    public init(willShow: Handler? = nil,
                didShow: Handler? = nil,
                willDismiss: Handler? = nil,
                didDismiss: Handler? = nil) {
        self.willShow = willShow
        self.didShow = didShow
        self.willDismiss = willDismiss
        self.didDismiss = didDismiss
    }
}
