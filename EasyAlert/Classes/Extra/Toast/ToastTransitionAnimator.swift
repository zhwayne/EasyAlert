//
//  ToastTransitionAnimator.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/13.
//

import Foundation

struct ToastTransitionAnimator : TransitionAnimator {
            
    private var constraints: [NSLayoutConstraint] = []
    
    var position: Toast.Position = .bottom
    
    func show(context: TransitionContext, completion: @escaping () -> Void) {
        
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
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
    
    func dismiss(context: TransitionContext, completion: @escaping () -> Void) {
        
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
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
    
    mutating func update(context: TransitionContext, layoutGuide: LayoutGuide) {
        
        context.backdropView.layoutIfNeeded()
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        defer {
            constraints.forEach { $0.priority -= 100 }
            NSLayoutConstraint.activate(constraints)
        }
        
        let edgeInsets = layoutGuide.edgeInsets
        let container = context.container
        let superview = context.backdropView
        
        // layout guide width.
        switch layoutGuide.width {
        case let .fixed(value):
            let width = value - (edgeInsets.left + edgeInsets.right)
            constraints.append(container.widthAnchor.constraint(equalToConstant: width))
            
        case let .flexible(value):
            let width = value - (edgeInsets.left + edgeInsets.right)
            constraints.append(container.widthAnchor.constraint(lessThanOrEqualToConstant: width))
            
        case let .multiplied(value, maximumWidth):
            let constant = -(edgeInsets.left + edgeInsets.right)
            let multiplierConstraint = container.widthAnchor.constraint(
                equalTo: superview.widthAnchor,
                multiplier: value,
                constant: constant)
            multiplierConstraint.priority = .required - 1
            constraints.append(multiplierConstraint)
            if let maximumWidth, maximumWidth > 0 {
                let maximumWidthConstraint = container.widthAnchor.constraint(lessThanOrEqualToConstant: maximumWidth)
                constraints.append(maximumWidthConstraint)
            }
        }
        
        // layout guide height.
        switch layoutGuide.height {
        case .automatic:
            let height = superview.frame.height
            let constraint = container.heightAnchor.constraint(lessThanOrEqualToConstant: height)
            constraints.append(constraint)
            
        case .fixed(let value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = container.heightAnchor.constraint(equalToConstant: height)
            constraints.append(constraint)
            
        case .flexible(let value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = container.heightAnchor.constraint(lessThanOrEqualToConstant: height)
            constraints.append(constraint)
            
        case .greaterThanOrEqualTo(let value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = container.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
            constraints.append(constraint)
        }
        
        switch position {
        case .center:
            let constraint = container.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            constraints.append(constraint)
        case .bottom:
            let bottomOffset = superview.frame.height * 0.15
            let constraint = container.bottomAnchor.constraint(
                equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -edgeInsets.bottom - bottomOffset)
            constraints.append(constraint)
        }
        
        constraints.append(container.centerXAnchor.constraint(equalTo: superview.centerXAnchor))
    }
}
