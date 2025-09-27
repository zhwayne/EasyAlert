//
//  AlertLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

/// A layout manager that handles the positioning and sizing of alert views.
///
/// `AlertLayout` implements the `AlertableLayout` protocol to provide standard
/// layout behavior for alerts, including width, height, and positioning constraints.
/// It supports flexible, fixed, and proportional sizing with proper constraint management.
final class AlertLayout: AlertableLayout {

    /// The array of active layout constraints that are currently applied to the alert.
    ///
    /// This array tracks all constraints created by the layout manager to ensure
    /// they can be properly deactivated and reactivated during layout updates.
    private var constraints: [NSLayoutConstraint] = []

    /// Updates the layout of the alert based on the provided context and layout guide.
    ///
    /// This method applies width, height, and positioning constraints to the alert
    /// based on the layout guide specifications. It handles different sizing modes
    /// including fixed, flexible, and proportional sizing with proper edge insets.
    ///
    /// - Parameters:
    ///   - context: The layout context containing views and layout information.
    ///   - layoutGuide: The layout guide that defines size and positioning constraints.
    func updateLayout(context: LayoutContext, layoutGuide: LayoutGuide) {

        // Deactivate existing constraints before applying new ones
        NSLayoutConstraint.deactivate(constraints)
        defer {
            NSLayoutConstraint.activate(constraints)
        }

        let edgeInsets = layoutGuide.contentInsets
        let presentedView = context.presentedView
        let containerView = context.containerView

        // Apply width constraints based on layout guide
        switch layoutGuide.width {
        case let .fixed(value):
            // Fixed width: alert has a specific width regardless of container size
            let width = value - (edgeInsets.left + edgeInsets.right)
            constraints.append(presentedView.widthAnchor.constraint(equalToConstant: width))

        case .flexible:
            // Flexible width: alert adapts to container width with insets
            let width = containerView.bounds.width - (edgeInsets.left + edgeInsets.right)
            constraints.append(presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: width))

        case let .multiplied(value, maxWidth):
            // Proportional width: alert width is a percentage of container width
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

        // Apply height constraints based on layout guide
        switch layoutGuide.height {
        case let .fixed(value):
            // Fixed height: alert has a specific height regardless of content
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(equalToConstant: height)
            constraints.append(constraint)

        case .flexible:
            // Flexible height: alert adapts to container height with insets
            let height = containerView.bounds.height - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(lessThanOrEqualToConstant: height)
            constraints.append(constraint)

        case let .greaterThanOrEqualTo(value):
            // Minimum height: alert has a minimum height but can grow larger
            let height = value - (edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
            constraints.append(constraint)
        }

        // Center the alert horizontally with edge inset compensation
        constraints.append(
            presentedView.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor,
                constant: (abs(edgeInsets.left) - abs(edgeInsets.right)) / 2
            )
        )
        
        // Center the alert vertically with edge inset compensation
        constraints.append(
            presentedView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor,
                constant: (abs(edgeInsets.top) - abs(edgeInsets.bottom))
            )
        )
    }
}
