//
//  SheetTransitionCoordinator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

struct SheetTransitionCoordinator : TransitionCoordinator {
    
    var duration: TimeInterval = 0.25
    
    var size: Size = Size(
        width: .multiplied(1),
        height: .automic
    )
    
    func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        context.container.layoutIfNeeded()
        let height = context.container.bounds.height
        context.container.transform = CGAffineTransform(translationX: 0, y: height)
        context.dimmingView.alpha = 0
        
        let timing = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
        animator.addAnimations {
            context.dimmingView.alpha = 1
            context.container.transform = .identity
        }
        animator.addCompletion { position in
            if position == .end { completion() }
        }
        animator.startAnimation()
    }
    
    func dismiss(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        context.container.layoutIfNeeded()
        let height = context.container.bounds.height
        
        let timing = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
        animator.addAnimations {
            context.dimmingView.alpha = 0
            context.container.transform = CGAffineTransform(translationX: 0, y: height)
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
                let constraint = context.container.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: value)
                constraint.isActive = true
                constraint.priority = .defaultHigh
            } else {
                context.container.widthAnchor.constraint(equalTo: superview.heightAnchor, multiplier: value).isActive = true
            }
        }
        if case let .greaterThanOrEqualTo(value) = size.height {
            context.container.heightAnchor.constraint(greaterThanOrEqualToConstant: value).isActive = true
        }
        context.container.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        context.container.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
}
