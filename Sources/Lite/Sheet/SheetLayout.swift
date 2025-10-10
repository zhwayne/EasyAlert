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

    private var activeConstraints: [NSLayoutConstraint] = []

    /// Updates constraints to position the sheet at the bottom with optional safe-area handling.
    func updateLayoutConstraints(context: LayoutContext, layoutGuide: LayoutGuide) {
        let container = context.containerView
        let presentedView = context.presentedView

        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints.removeAll()

        presentedView.translatesAutoresizingMaskIntoConstraints = false

        // Horizontal sizing
        switch layoutGuide.width {
        case let .fixed(value):
            let w = max(0, value - (layoutGuide.contentInsets.left + layoutGuide.contentInsets.right))
            activeConstraints.append(presentedView.widthAnchor.constraint(equalToConstant: w))
        case let .fractional(f):
            let insetSum = layoutGuide.contentInsets.left + layoutGuide.contentInsets.right
            let c = -insetSum
            activeConstraints.append(presentedView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: max(0, f), constant: c))
        case .intrinsic:
            // For sheets, intrinsic width allows the view to size itself within available space
            let safeInsets = container.safeAreaInsets
            let leftSafe = layoutGuide.edgesForExtendedSafeArea.contains(.left) ? 0 : safeInsets.left
            let rightSafe = layoutGuide.edgesForExtendedSafeArea.contains(.right) ? 0 : safeInsets.right
            let available = max(0, container.bounds.width - leftSafe - rightSafe - layoutGuide.contentInsets.left - layoutGuide.contentInsets.right)
            activeConstraints.append(presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: available))
        }

        // Vertical sizing
        switch layoutGuide.height {
        case let .fixed(value):
            let h = max(0, value - (layoutGuide.contentInsets.top + layoutGuide.contentInsets.bottom))
            activeConstraints.append(presentedView.heightAnchor.constraint(equalToConstant: h))
        case let .fractional(f):
            let insetSum = layoutGuide.contentInsets.top + layoutGuide.contentInsets.bottom
            let c = -insetSum
            activeConstraints.append(presentedView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: max(0, f), constant: c))
        case .intrinsic:
            // Let the sheet size itself based on its intrinsic content size
            // No height constraint is added, allowing the view to size itself
            break
        }

        // Horizontal position center
        activeConstraints.append(presentedView.centerXAnchor.constraint(equalTo: container.centerXAnchor))

        // Bottom position considering safe-area preference
        let bottomAnchor = layoutGuide.edgesForExtendedSafeArea.contains(.bottom) ? container.bottomAnchor : container.safeAreaLayoutGuide.bottomAnchor
        activeConstraints.append(presentedView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -layoutGuide.contentInsets.bottom))

        NSLayoutConstraint.activate(activeConstraints)
    }
}
