//
//  SheetTransitionCoordinator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

struct SheetTransitionCoordinator : TransitionCoordinator {
    
    var duration: TimeInterval = 0.25
    
    var layoutGuide = LayoutGuide(width: .multiplied(1, maximumWidth: 414))
    
    private var constraints: [NSLayoutConstraint] = []
    
    func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        context.container.superview?.isUserInteractionEnabled = false
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
            completion()
            context.container.superview?.isUserInteractionEnabled = true
        }
        animator.startAnimation()
    }
    
    func dismiss(context: TransitionCoordinatorContext, completion: @escaping () -> Void) {
        context.container.superview?.isUserInteractionEnabled = false
        context.container.layoutIfNeeded()
        let height = context.frame.height - context.container.frame.minY
        
        let timing = UICubicTimingParameters(animationCurve: .easeOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
        animator.addAnimations {
            context.dimmingView.alpha = 0
            context.container.transform = CGAffineTransform(translationX: 0, y: height)
        }
        animator.addCompletion { position in
            completion()
            context.container.superview?.isUserInteractionEnabled = true
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
        
        if layoutGuide.ignoreBottomSafeArea {
            let constraint = container.bottomAnchor.constraint(
                equalTo: superview.bottomAnchor, constant: -edgeInsets.bottom)
            constraints.append(constraint)
        } else {
            let constraint =  container.bottomAnchor.constraint(
                equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -edgeInsets.bottom)
            constraints.append(constraint)
        }
        
        constraints.append(container.centerXAnchor.constraint(equalTo: superview.centerXAnchor))
    }
}

