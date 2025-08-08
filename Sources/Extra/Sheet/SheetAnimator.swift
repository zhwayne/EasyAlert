//
//  SheetAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

struct SheetAnimator : AlertbleAnimator {
    
    func show(context: LayoutContext, completion: @escaping () -> Void) {
        let height = context.presentedView.bounds.height + context.dimmingView.safeAreaInsets.bottom
        context.presentedView.transform = CGAffineTransform(translationX: 0, y: height)
        context.dimmingView.alpha = 0
        
        withSpringTimingAnimation {
            context.dimmingView.alpha = 1
            context.presentedView.transform = .identity
        } completion: { _ in
            completion()
        }
    }
    
    func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        context.presentedView.layoutIfNeeded()
        let height = context.frame.height - context.presentedView.frame.minY
        
        withSpringTimingAnimation {
            context.dimmingView.alpha = 0
            context.presentedView.alpha = 0.5
            context.presentedView.transform = CGAffineTransform(translationX: 0, y: height)
        } completion: { _ in
            completion()
        }
    }
}
