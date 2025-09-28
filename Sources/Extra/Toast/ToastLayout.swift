//
//  ToastLayout.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import UIKit

/// A layout manager that handles the positioning and sizing of toast notifications.
///
/// `ToastLayout` implements the `AlertableLayout` protocol to provide flexible
/// layout management for toast notifications. It supports both center and bottom
/// positioning with responsive sizing based on content and screen dimensions.
final class ToastLayout: AlertableLayout {

    /// The position where the toast should be displayed on the screen.
    ///
    /// This property determines whether the toast appears in the center or at the
    /// bottom of the screen, affecting the layout calculations and constraints.
    var position: Toast.Position = .bottom
    
    /// An array of active layout constraints for the toast view.
    ///
    /// This property stores the constraints that position and size the toast view,
    /// allowing for proper constraint management and updates.
    private var constraints: [NSLayoutConstraint] = []

    /// Updates the layout of the toast view based on the provided context and layout guide.
    ///
    /// This method calculates and applies the appropriate constraints for the toast view,
    /// taking into account the position, content insets, and layout guide specifications.
    /// It handles both width and height constraints with support for fixed, flexible,
    /// and multiplied sizing options.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to be laid out.
    ///   - layoutGuide: The layout guide that defines sizing and positioning constraints.
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
            let width = min(containerView.bounds.width, containerView.bounds.height) - (edgeInsets.left + edgeInsets.right)
            constraints.append(presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: width))

        case let .fractional(value):
            let constant = -(edgeInsets.left + edgeInsets.right)
            let constraint = presentedView.widthAnchor.constraint(
                equalTo: containerView.widthAnchor,
                multiplier: value,
                constant: constant)
            constraint.priority = .required - 1
            constraints.append(constraint)
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

        case let .fractional(value):
            let constant = -(edgeInsets.top + edgeInsets.bottom)
            let constraint = presentedView.heightAnchor.constraint(
                equalTo: containerView.heightAnchor,
                multiplier: value,
                constant: constant)
            constraint.priority = .required - 1
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
