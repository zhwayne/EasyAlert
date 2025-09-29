//
//  SheetLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

/// A layout manager that handles the positioning and sizing of sheet presentations.
///
/// `SheetLayout` implements the `AlertableLayout` protocol to provide flexible
/// layout management for sheet presentations. It supports various sizing options
/// and positions sheets at the bottom of the screen with proper safe area handling.
final class SheetLayout: AlertableLayout {

    /// An array of active layout constraints for the sheet view.
    ///
    /// This property stores the constraints that position and size the sheet view,
    /// allowing for proper constraint management and updates.
    private var constraints: [NSLayoutConstraint] = []

    /// Updates the layout of the sheet view based on the provided context and layout guide.
    ///
    /// This method calculates and applies the appropriate constraints for the sheet view,
    /// taking into account the layout guide specifications, content insets, and safe area
    /// requirements. It handles both width and height constraints with support for
    /// fixed, flexible, and multiplied sizing options.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to be laid out.
    ///   - layoutGuide: The layout guide that defines sizing and positioning constraints.
    func updateLayout(context: LayoutContext, layoutGuide: LayoutGuide) {

        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll(keepingCapacity: true)
        defer { NSLayoutConstraint.activate(constraints) }

        let edgeInsets = layoutGuide.contentInsets
        let presentedView = context.presentedView
        let containerView = context.containerView

        // layout guide width.
        switch layoutGuide.width {
        case let .fixed(value):
            var width = value - (edgeInsets.left + edgeInsets.right)
            if context.interfaceOrientation.isLandscape {
                width = min(width, 414)
            }
            constraints.append(presentedView.widthAnchor.constraint(equalToConstant: width))

        case .flexible:
            let width = containerView.bounds.width - (edgeInsets.left + edgeInsets.right)
            constraints.append(presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: width))
            if context.interfaceOrientation.isLandscape {
                constraints.append(presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: 414))
            }

        case let .fractional(value):
            let constant = -(edgeInsets.left + edgeInsets.right)
            let constraint = presentedView.widthAnchor.constraint(
                equalTo: containerView.widthAnchor,
                multiplier: value,
                constant: constant)
            constraint.priority = .required - 1
            constraints.append(constraint)
            if context.interfaceOrientation.isLandscape {
                constraints.append(presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: 414))
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

        case .fractional(let value):
            let constant = -(edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(
                equalTo: containerView.heightAnchor,
                multiplier: value,
                constant: constant)
            constraint.priority = .required - 1
            constraints.append(constraint)
        }

        if layoutGuide.ignoredSafeAreaEdges.contains(.bottom) {
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
