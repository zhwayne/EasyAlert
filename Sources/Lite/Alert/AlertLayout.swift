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
final class AlertLayout: AlertableLayout {

    /// The array of active layout constraints.
    private var constraints: [NSLayoutConstraint] = []

    /// Updates the layout of the alert based on the provided context and layout guide.
    ///
    /// - Parameters:
    ///   - context: The layout context containing views and layout information.
    ///   - layoutGuide: The layout guide that defines size and positioning constraints.
    func updateLayout(context: LayoutContext, layoutGuide: LayoutGuide) {

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

        constraints.append(
            presentedView.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor,
                constant: (abs(edgeInsets.left) - abs(edgeInsets.right)) / 2
            )
        )
        constraints.append(
            presentedView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor,
                constant: (abs(edgeInsets.top) - abs(edgeInsets.bottom))
            )
        )
    }
}
