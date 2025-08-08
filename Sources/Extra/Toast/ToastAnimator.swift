//
//  ToastAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

struct ToastAnimator : AlertbleAnimator {
    
    func show(context: LayoutContext, completion: @escaping () -> Void) {
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        context.presentedView.transform = transform
        context.presentedView.alpha = 0
        
        withSpringTimingAnimation {
            context.presentedView.alpha = 1
            context.presentedView.transform = .identity
        } completion: { _ in
            completion()
        }
    }
    
    func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        withSpringTimingAnimation {
            context.presentedView.alpha = 0
            context.presentedView.transform = transform
        } completion: { _ in
            completion()
        }
    }
}
