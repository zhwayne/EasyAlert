//
//  ToastLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

final class ToastLayout: AlertableLayout {
    
    var position: Toast.Position = .bottom
    private var constraints: [NSLayoutConstraint] = []
    
    func update(context: LayoutContext, layoutGuide: LayoutGuide) {
        
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
            let width = min(containerView.bounds.width, containerView.bounds.height) - (edgeInsets.left + edgeInsets.right)
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
        case let .fixed(value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(equalToConstant: height)
            constraints.append(constraint)
            
        case .flexible:
            let height = containerView.bounds.height - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(lessThanOrEqualToConstant: height)
            constraints.append(constraint)
            
        case let .greaterThanOrEqualTo(value):
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
            constraints.append(constraint)
        }
        
        switch position {
        case .center:
            let constraint = presentedView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            constraints.append(constraint)
        case .bottom:
            // FIXME: 横屏和竖屏场景下，toast 底部的高度应定由当前设备方向高度重新计算
            let bottomOffset = if containerView.frame.height > containerView.frame.width {
                containerView.frame.height * 0.15
            } else {
                containerView.frame.height * 0.15
            }
            let constraint = presentedView.bottomAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -edgeInsets.bottom - bottomOffset)
            constraints.append(constraint)
        }
        
        constraints.append(presentedView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor))
    }
}
