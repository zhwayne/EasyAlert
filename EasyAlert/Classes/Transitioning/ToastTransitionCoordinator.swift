//
//  ToastTransitionCoordinator.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/13.
//

import Foundation

struct ToastTransitionCoordinator : TransitionCoordinator {
    
    var layoutGuide = LayoutGuide(width: .flexible(UIScreen.main.bounds.size.width * 0.8))
        
    private var constraints: [NSLayoutConstraint] = []
    
    func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        context.container.layoutIfNeeded()
        
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: 20)
        context.container.transform = transform
        context.container.alpha = 0
        
        let timing = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: 1/* This value will be ignored.*/, timingParameters: timing)
        animator.addAnimations {
            context.container.alpha = 1
            context.container.transform = .identity
        }
        animator.addCompletion { position in
            completion()
        }
        animator.startAnimation()
    }
    
    func dismiss(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        context.container.layoutIfNeeded()
        
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: 8)
        
        let timing = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: 1/* This value will be ignored.*/, timingParameters: timing)
        animator.addAnimations {
            context.container.alpha = 0
            context.container.transform = transform
        }
        animator.addCompletion { position in
            completion()
        }
        animator.startAnimation()
    }
    
    mutating func update(context: TransitionCoordinatorContext) {

        context.backdropView.layoutIfNeeded()
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        defer { NSLayoutConstraint.activate(constraints) }
        
        let edgeInsets = layoutGuide.edgeInsets
        let container = context.container
        let superview = context.backdropView
        
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
        
        let bottomOffset = superview.frame.height * 0.15
        let constraint = container.bottomAnchor.constraint(
            equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -edgeInsets.bottom - bottomOffset)
        constraints.append(constraint)
        
        constraints.append(container.centerXAnchor.constraint(equalTo: superview.centerXAnchor))
    }
}
