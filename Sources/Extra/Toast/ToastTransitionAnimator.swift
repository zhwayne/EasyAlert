//
//  ToastTransitionAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

struct ToastTransitionAnimator : TransitionAnimator {
            
    private var constraints: [NSLayoutConstraint] = []
    
    var position: Toast.Position = .bottom
    
    func show(context: TransitionContext, completion: @escaping () -> Void) {
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        context.container.transform = transform
        context.container.alpha = 0
        
        withSpringTimingAnimation {
            context.container.alpha = 1
            context.container.transform = .identity
        } completion: { _ in
            completion()
        }
    }
    
    func dismiss(context: TransitionContext, completion: @escaping () -> Void) {
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        withSpringTimingAnimation {
            context.container.alpha = 0
            context.container.transform = transform
        } completion: { _ in
            completion()
        }
    }
    
    mutating func update(context: TransitionContext, layoutGuide: LayoutGuide) {
        
        context.backdropView.layoutIfNeeded()
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        defer {
            NSLayoutConstraint.activate(constraints)
        }
        
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
