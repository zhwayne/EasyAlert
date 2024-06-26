//
//  AlertTransitionAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

struct AlertTransitionAnimator : TransitionAnimator {
    
    private var constraints: [NSLayoutConstraint] = []
    
    func show(with context: TransitionContext, completion: @escaping () -> Void) {
        context.container.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        context.container.alpha = 0
        context.dimmingView.alpha = 0

        withSpringTimingAnimation {
            context.dimmingView.alpha = 1
            context.container.alpha = 1
            context.container.transform = .identity
        } completion: { _ in
            completion()
        }
    }
    
    func dismiss(with context: TransitionContext, completion: @escaping () -> Void) {
        withSpringTimingAnimation {
            context.container.alpha = 0
            context.dimmingView.alpha = 0
        } completion: { _ in
            completion()
        }
    }
    
    mutating func update(with context: TransitionContext) {

        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        defer {
            constraints.forEach { $0.priority -= 100 }
            NSLayoutConstraint.activate(constraints)
        }
        
        let layoutGuide = context.layoutGuide
        let edgeInsets = layoutGuide.contentInsets
        let container = context.container
        guard let superview = container.superview else { return }

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
            
        case let .fixed(value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = container.heightAnchor.constraint(equalToConstant: height)
            constraints.append(constraint)
            
        case let .flexible(value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = container.heightAnchor.constraint(lessThanOrEqualToConstant: height)
            constraints.append(constraint)
            
        case let .greaterThanOrEqualTo(value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = container.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
            constraints.append(constraint)
            
        case let .multiplied(value, maximumHeight):
            let constant = -(edgeInsets.top + edgeInsets.bottom)
            let multiplierConstraint = container.heightAnchor.constraint(
                equalTo: superview.heightAnchor,
                multiplier: value,
                constant: constant)
            multiplierConstraint.priority = .required - 1
            constraints.append(multiplierConstraint)
            if let maximumHeight, maximumHeight > 0 {
                let maximumHeightConstraint = container.heightAnchor.constraint(lessThanOrEqualToConstant: maximumHeight)
                constraints.append(maximumHeightConstraint)
            }
        }
        
        constraints.append(
            container.centerXAnchor.constraint(
                equalTo: superview.centerXAnchor,
                constant: (abs(edgeInsets.left) - abs(edgeInsets.right)) / 2))
        constraints.append(
            container.centerYAnchor.constraint(
                equalTo: superview.centerYAnchor,
                constant: (abs(edgeInsets.top) - abs(edgeInsets.bottom)) / 2 + 10))
    }
}
