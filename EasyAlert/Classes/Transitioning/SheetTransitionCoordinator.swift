//
//  SheetTransitionCoordinator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

struct SheetTransitionCoordinator : TransitionCoordinator {
    
    var duration: TimeInterval = 0.25
    
    var layoutGuide = LayoutGuide(width: .multiplied(1))
    
    func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        context.container.layoutIfNeeded()
        let height = context.container.bounds.height + context.dimmingView.safeAreaInsets.bottom
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
        let height = context.frame.height - context.container.frame.minY
        
        let timing = UICubicTimingParameters(animationCurve: .easeOut)
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
        
        let edgeInsets = layoutGuide.edgeInsets
        let container = context.container
        
        switch layoutGuide.width {
        case let .fixed(value):
            let width = value + (edgeInsets.left + edgeInsets.right)
            container.widthAnchor
                .constraint(equalToConstant: width)
                .isActive = true
            
        case let .flexible(value):
            let width = value + (edgeInsets.left + edgeInsets.right)
            container.widthAnchor
                .constraint(lessThanOrEqualToConstant: width)
                .isActive = true
            
        case let .multiplied(value):
            let constant = edgeInsets.left + edgeInsets.left
            if context.interfaceOrientation.isPortrait {
                container.widthAnchor
                    .constraint(equalTo: superview.widthAnchor, multiplier: value, constant: constant)
                    .isActive = true
            } else {
                container.widthAnchor
                    .constraint(equalTo: superview.heightAnchor, multiplier: value, constant: constant)
                    .isActive = true
            }
        }
        if case let .greaterThanOrEqualTo(value) = layoutGuide.height {
            let height = value + edgeInsets.top + edgeInsets.bottom
            container.heightAnchor
                .constraint(greaterThanOrEqualToConstant: height)
                .isActive = true
        } else {
            let height = edgeInsets.top + edgeInsets.bottom
            container.heightAnchor
                .constraint(greaterThanOrEqualToConstant: height)
                .isActive = true
        }
        container.centerXAnchor
            .constraint(equalTo: superview.centerXAnchor)
            .isActive = true
        
        if layoutGuide.ignoreBottomSafeArea {
            container.bottomAnchor
                .constraint(equalTo: superview.bottomAnchor, constant: -edgeInsets.bottom)
                .isActive = true
        } else {
            container.bottomAnchor
                .constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -edgeInsets.bottom)
                .isActive = true
        }
    }
}
