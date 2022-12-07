//
//  AlertTransitionCoordinator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

struct AlertTransitionCoordinator : TransitionCoordinator {
    
    var duration: TimeInterval = 0.25
    
    var size: Size = Size(
        width: .fixed(270),
        height: .automic
    )
    
    func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        context.container.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        context.container.alpha = 0
        context.dimmingView.alpha = 0

        let timing = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
        animator.addAnimations {
            context.dimmingView.alpha = 1
            context.container.alpha = 1
            context.container.transform = .identity
        }
        animator.addCompletion { position in
            if position == .end { completion() }
        }
        animator.startAnimation()
    }
    
    func dismiss(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        let timing = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
        animator.addAnimations {
            context.container.alpha = 0
            context.dimmingView.alpha = 0
        }
        animator.addCompletion { position in
            if position == .end { completion() }
        }
        animator.startAnimation()
    }
    
    func update(context: TransitionCoordinatorContext) {
        guard let superview = context.container.superview else { return }
        NSLayoutConstraint.deactivate(context.container.constraints)
        switch size.width {
        case let .fixed(value): context.container.widthAnchor.constraint(equalToConstant: value).isActive = true
        case let .flexible(value): context.container.widthAnchor.constraint(lessThanOrEqualToConstant: value).isActive = true
        case let .multiplied(value):
            if context.interfaceOrientation.isPortrait {
                context.container.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: value).isActive = true
            } else {
                context.container.widthAnchor.constraint(equalTo: superview.heightAnchor, multiplier: value).isActive = true
            }
        }
        if case let .greaterThanOrEqualTo(value) = size.height {
            context.container.heightAnchor.constraint(greaterThanOrEqualToConstant: value).isActive = true
        }
        context.container.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        context.container.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
    }
}
