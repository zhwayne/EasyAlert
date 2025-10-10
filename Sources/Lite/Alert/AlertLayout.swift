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

    private var activeConstraints: [NSLayoutConstraint] = []

    /// Updates (re-installs) constraints for the presented view using the current `layoutGuide`.
    func updateLayoutConstraints(context: LayoutContext, layoutGuide: LayoutGuide) {
        let container = context.containerView
        let presentedView = context.presentedView

        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints.removeAll()

        presentedView.translatesAutoresizingMaskIntoConstraints = false

        // Determine reference anchors based on safe-area extension preferences
        let edges = layoutGuide.edgesForExtendedSafeArea
        let topRef = edges.contains(.top) ? container.topAnchor : container.safeAreaLayoutGuide.topAnchor
        let leftRef = edges.contains(.left) ? container.leftAnchor : container.safeAreaLayoutGuide.leftAnchor
        let bottomRef = edges.contains(.bottom) ? container.bottomAnchor : container.safeAreaLayoutGuide.bottomAnchor
        let rightRef = edges.contains(.right) ? container.rightAnchor : container.safeAreaLayoutGuide.rightAnchor

        // Always keep inside insets
        activeConstraints.append(presentedView.topAnchor.constraint(greaterThanOrEqualTo: topRef, constant: layoutGuide.contentInsets.top))
        activeConstraints.append(presentedView.leftAnchor.constraint(greaterThanOrEqualTo: leftRef, constant: layoutGuide.contentInsets.left))
        activeConstraints.append(presentedView.rightAnchor.constraint(lessThanOrEqualTo: rightRef, constant: -layoutGuide.contentInsets.right))
        activeConstraints.append(presentedView.bottomAnchor.constraint(lessThanOrEqualTo: bottomRef, constant: -layoutGuide.contentInsets.bottom))

        // Center within container
        activeConstraints.append(presentedView.centerXAnchor.constraint(equalTo: container.centerXAnchor))
        activeConstraints.append(presentedView.centerYAnchor.constraint(equalTo: container.centerYAnchor))

        // Size rules
        switch layoutGuide.width {
        case let .fixed(value):
            let width = max(0, value - (layoutGuide.contentInsets.left + layoutGuide.contentInsets.right))
            activeConstraints.append(presentedView.widthAnchor.constraint(equalToConstant: width))
        case let .fractional(f):
            let insetSum = layoutGuide.contentInsets.left + layoutGuide.contentInsets.right
            let ref = container.widthAnchor
            let c = -insetSum
            activeConstraints.append(presentedView.widthAnchor.constraint(equalTo: ref, multiplier: max(0, f), constant: c))
        case .intrinsic:
            // For alerts, intrinsic width allows the view to size itself within available space
            let safeInsets = container.safeAreaInsets
            let leftSafe = edges.contains(.left) ? 0 : safeInsets.left
            let rightSafe = edges.contains(.right) ? 0 : safeInsets.right
            let available = max(0, container.bounds.width - leftSafe - rightSafe - layoutGuide.contentInsets.left - layoutGuide.contentInsets.right)
            activeConstraints.append(presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: available))
        }

        switch layoutGuide.height {
        case let .fixed(value):
            let height = max(0, value - (layoutGuide.contentInsets.top + layoutGuide.contentInsets.bottom))
            activeConstraints.append(presentedView.heightAnchor.constraint(equalToConstant: height))
        case let .fractional(f):
            let insetSum = layoutGuide.contentInsets.top + layoutGuide.contentInsets.bottom
            let ref = container.heightAnchor
            let c = -insetSum
            activeConstraints.append(presentedView.heightAnchor.constraint(equalTo: ref, multiplier: max(0, f), constant: c))
        case .intrinsic:
            // For alerts, intrinsic height allows the view to size itself within available space
            let safeInsets = container.safeAreaInsets
            let topSafe = edges.contains(.top) ? 0 : safeInsets.top
            let bottomSafe = edges.contains(.bottom) ? 0 : safeInsets.bottom
            let available = max(0, container.bounds.height - topSafe - bottomSafe - layoutGuide.contentInsets.top - layoutGuide.contentInsets.bottom)
            activeConstraints.append(presentedView.heightAnchor.constraint(lessThanOrEqualToConstant: available))
        }

        NSLayoutConstraint.activate(activeConstraints)
    }
}
