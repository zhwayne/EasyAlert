//
//  ToastLayoutModifier.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

struct ToastLayoutModifier: LayoutModifier {
    
    var position: Toast.Position = .bottom
    
    func update(context: LayoutContext, layoutGuide: LayoutGuide) {
        var constraints: [NSLayoutConstraint] = []
        
        context.containerView.layoutIfNeeded()
        NSLayoutConstraint.deactivate(constraints)

        defer {
            NSLayoutConstraint.activate(constraints)
        }
        
        let edgeInsets = layoutGuide.contentInsets
        let presentedView = context.presentedView
        let containerView = context.containerView

        // layout guide width.
        switch layoutGuide.width {
        case let .fixed(value):
            let width = value - (edgeInsets.left + edgeInsets.right)
            constraints.append(presentedView.widthAnchor.constraint(equalToConstant: width))
            
        case let .flexible(value):
            let width = value - (edgeInsets.left + edgeInsets.right)
            constraints.append(presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: width))
            
        case let .multiplied(value, maximumWidth):
            let constant = -(edgeInsets.left + edgeInsets.right)
            let multiplierConstraint = presentedView.widthAnchor.constraint(
                equalTo: containerView.widthAnchor,
                multiplier: value,
                constant: constant)
            multiplierConstraint.priority = .required - 1
            constraints.append(multiplierConstraint)
            if let maximumWidth, maximumWidth > 0 {
                let maximumWidthConstraint = presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: maximumWidth)
                constraints.append(maximumWidthConstraint)
            }
        }
        
        // layout guide height.
        switch layoutGuide.height {
        case .automatic:
            let height = containerView.frame.height
            let constraint = presentedView.heightAnchor.constraint(lessThanOrEqualToConstant: height)
            constraints.append(constraint)
            
        case .fixed(let value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(equalToConstant: height)
            constraints.append(constraint)
            
        case .flexible(let value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(lessThanOrEqualToConstant: height)
            constraints.append(constraint)
            
        case .greaterThanOrEqualTo(let value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
            constraints.append(constraint)
            
        case let .multiplied(value, maximumHeight):
            let constant = -(edgeInsets.top + edgeInsets.bottom)
            let multiplierConstraint = presentedView.heightAnchor.constraint(
                equalTo: containerView.heightAnchor,
                multiplier: value,
                constant: constant)
            multiplierConstraint.priority = .required - 1
            constraints.append(multiplierConstraint)
            if let maximumHeight, maximumHeight > 0 {
                let maximumHeightConstraint = presentedView.heightAnchor.constraint(lessThanOrEqualToConstant: maximumHeight)
                constraints.append(maximumHeightConstraint)
            }
        }
        
        switch position {
        case .center:
            let constraint = presentedView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            constraints.append(constraint)
        case .bottom:
            let bottomOffset = containerView.frame.height * 0.15
            let constraint = presentedView.bottomAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -edgeInsets.bottom - bottomOffset)
            constraints.append(constraint)
        }
        
        constraints.append(presentedView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor))
    }
}
