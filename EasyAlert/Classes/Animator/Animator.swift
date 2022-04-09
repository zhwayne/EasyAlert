//
//  Animator.swift
//  EasyAlert
//
//  Created by iya on 2021/12/13.
//

import Foundation

public struct AnimatorContext {
    
    public let container: UIView
    
    public let dimmingView: UIView
}

public protocol Animator {
    
    func show(context: AnimatorContext, completion: @escaping () -> Void)
    
    func dismiss(context: AnimatorContext, completion: @escaping () -> Void)
}
