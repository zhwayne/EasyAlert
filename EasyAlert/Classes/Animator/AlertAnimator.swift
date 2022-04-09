//
//  AlertAnimator.swift
//  EasyAlert
//
//  Created by iya on 2021/12/17.
//

import Foundation

struct AlertAnimator: Animator {
    
    func show(context: AnimatorContext, completion: @escaping () -> Void) {
        context.container.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        context.container.alpha = 0
        context.dimmingView.alpha = 0
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            context.dimmingView.alpha = 1
            context.container.alpha = 1
            context.container.transform = .identity
        } completion: { _ in
            completion()
        }
    }
    
    func dismiss(context: AnimatorContext, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            context.container.alpha = 0
            context.dimmingView.alpha = 0
        } completion: { finished in
            completion()
        }
    }
}
