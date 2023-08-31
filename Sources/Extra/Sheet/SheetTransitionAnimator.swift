//
//  SheetTransitionAnimator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

struct SheetTransitionAnimator : TransitionAnimator {
            
    private var constraints: [NSLayoutConstraint] = []
    
    private weak var sheet: Sheet?
    
    init(sheet: Sheet) {
        self.sheet = sheet
    }
    
    func show(context: TransitionContext, completion: @escaping () -> Void) {
        let height = context.container.bounds.height + context.dimmingView.safeAreaInsets.bottom
        context.container.transform = CGAffineTransform(translationX: 0, y: height)
        context.dimmingView.alpha = 0
        
        let timing = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: 1/* This value will be ignore.*/, timingParameters: timing)
        animator.addAnimations {
            context.dimmingView.alpha = 1
            context.container.transform = .identity
        }
        animator.addCompletion { position in
            completion()
        }
        animator.startAnimation()
    }
    
    func dismiss(context: TransitionContext, completion: @escaping () -> Void) {
        context.container.layoutIfNeeded()
        let height = context.frame.height - context.container.frame.minY
        
        let timing = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: 1/* This value will be ignored.*/, timingParameters: timing)
        animator.addAnimations {
            context.dimmingView.alpha = 0
            context.container.transform = CGAffineTransform(translationX: 0, y: height)
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
        
        if let sheet, sheet.ignoreBottomSafeArea {
            let constraint = container.bottomAnchor.constraint(
                equalTo: superview.bottomAnchor,
                constant: -edgeInsets.bottom)
            constraints.append(constraint)
        } else {
            let constraint =  container.bottomAnchor.constraint(
                equalTo: superview.safeAreaLayoutGuide.bottomAnchor,
                constant: -edgeInsets.bottom)
            constraints.append(constraint)
        }
        
        constraints.append(
            container.centerXAnchor.constraint(
                equalTo: superview.centerXAnchor,
                constant: (abs(edgeInsets.left) - abs(edgeInsets.right)) / 2))
    }
}
