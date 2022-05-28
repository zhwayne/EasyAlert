//
//  SheetAnimator.swift
//  EasyAlert
//
//  Created by iya on 2021/12/17.
//

import Foundation

struct SheetAnimator: Animator {
    
    var duration: TimeInterval = 0.25
    
    func show(context: AnimatorContext, completion: @escaping () -> Void) {
        context.container.layoutIfNeeded()
        let height = context.container.bounds.height
        context.container.transform = CGAffineTransform(translationX: 0, y: height)
        context.dimmingView.alpha = 0
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            context.dimmingView.alpha = 1
            context.container.alpha = 1
            context.container.transform = .identity
        } completion: { _ in
            completion()
        }
    }
    
    func dismiss(context: AnimatorContext, completion: @escaping () -> Void) {
        context.container.layoutIfNeeded()
        let height = context.container.bounds.height
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            context.dimmingView.alpha = 0
            context.container.transform = CGAffineTransform(translationX: 0, y: height)
        } completion: { finished in
            completion()
        }
    }
}
