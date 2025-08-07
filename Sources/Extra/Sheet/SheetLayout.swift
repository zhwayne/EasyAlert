//
//  SheetLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

final class SheetLayout: AlertableLayout {
    
    private var constraints: [NSLayoutConstraint] = []
    
    func updateLayout(context: LayoutContext, layoutGuide: AlertLayoutGuide) {
        
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
            
        case .flexible:
            let width = containerView.bounds.width - (edgeInsets.left + edgeInsets.right)
            constraints.append(presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: width))
            
        case let .multiplied(value, maxWidth):
            let constant = -(edgeInsets.left + edgeInsets.right)
            let multiplierConstraint = presentedView.widthAnchor.constraint(
                equalTo: containerView.widthAnchor,
                multiplier: value,
                constant: constant)
            multiplierConstraint.priority = .required - 1
            constraints.append(multiplierConstraint)
            if let maxWidth, maxWidth > 0 {
                let maxWidthConstraint = presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth)
                constraints.append(maxWidthConstraint)
            }
        }
        
        // layout guide height.
        switch layoutGuide.height {
        case .fixed(let value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(equalToConstant: height)
            constraints.append(constraint)
            
        case .flexible:
            let height = containerView.bounds.height - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(lessThanOrEqualToConstant: height)
            constraints.append(constraint)
            
        case .greaterThanOrEqualTo(let value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
            constraints.append(constraint)
        }
        
        if layoutGuide.ignoresSafeAreaBottom {
            let constraint = presentedView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -edgeInsets.bottom)
            constraints.append(constraint)
        } else {
            let constraint =  presentedView.bottomAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.bottomAnchor,
                constant: -edgeInsets.bottom)
            constraints.append(constraint)
        }
        
        constraints.append(
            presentedView.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor,
                constant: (abs(edgeInsets.left) - abs(edgeInsets.right)) / 2)
        )
    }
}
