//
//  AlertTransitionCoordinator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

struct AlertTransitionCoordinator : TransitionCoordinator {
    
    var duration: TimeInterval = 0.25

    var layoutGuide = LayoutGuide(width: .fixed(270))
    
    private var constraints: [NSLayoutConstraint] = []
    
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
            completion()
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
            completion()
        }
        animator.startAnimation()
    }
    
    mutating func update(context: TransitionCoordinatorContext) {
        guard let superview = context.container.superview else { return }
        superview.layoutIfNeeded()
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        defer { NSLayoutConstraint.activate(constraints) }
        
        let edgeInsets = layoutGuide.edgeInsets
        let container = context.container
        
        switch layoutGuide.width {
        case let .fixed(value):
            let width = value + (edgeInsets.left + edgeInsets.right)
            constraints.append(container.widthAnchor.constraint(equalToConstant: width))
            
        case let .flexible(value):
            let width = value + (edgeInsets.left + edgeInsets.right)
            constraints.append(container.widthAnchor.constraint(lessThanOrEqualToConstant: width))
            
        case let .multiplied(value, maximumWidth):
            let constant = edgeInsets.left + edgeInsets.left
            let multiplierConstraint = container.widthAnchor.constraint(
                equalTo: superview.widthAnchor, multiplier: value, constant: constant)
            multiplierConstraint.priority = .required - 1
            constraints.append(multiplierConstraint)
            if maximumWidth > 0 {
                let maximumWidthConstraint = container.widthAnchor
                    .constraint(lessThanOrEqualToConstant: maximumWidth)
                constraints.append(maximumWidthConstraint)
            }
        }
        
        if case let .greaterThanOrEqualTo(value) = layoutGuide.height {
            let height = value + edgeInsets.top + edgeInsets.bottom
            let constraint = container.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
            constraints.append(constraint)
        } else {
            let height = edgeInsets.top + edgeInsets.bottom
            let constraint = container.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
            constraints.append(constraint)
        }
        
        constraints.append(container.centerXAnchor.constraint(equalTo: superview.centerXAnchor))
        constraints.append(container.centerYAnchor.constraint(equalTo: superview.centerYAnchor))
    }
}
