//
//  AlertTransitionAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

struct AlertTransitionAnimator : TransitionAnimator {
    
    func show(context: LayoutContext, completion: @escaping () -> Void) {
        context.presentedView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        context.presentedView.alpha = 0
        context.dimmingView.alpha = 0

        withSpringTimingAnimation {
            context.dimmingView.alpha = 1
            context.presentedView.alpha = 1
            context.presentedView.transform = .identity
        } completion: { _ in
            completion()
        }
    }
    
    func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        withSpringTimingAnimation {
            context.presentedView.alpha = 0
            context.dimmingView.alpha = 0
        } completion: { _ in
            completion()
        }
    }

}
