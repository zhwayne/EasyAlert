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
    /// bottom of the screen, affecting the frame calculation below.
    var position: Toast.Position = .bottom

    /// Updates the layout of the toast view based on the provided context and layout guide.
    ///
    /// The toast layout now relies on frame calculations. The presented view is measured
    /// using Auto Layout and positioned either at the vertical center or above the bottom
    /// edge with a proportional offset to mimic the previous constraint-based behaviour,
    /// returning the final frame without mutating constraints directly.
    ///
    /// - Parameters:
    ///   - context: The layout context containing the views to be laid out.
    ///   - layoutGuide: The layout guide that defines sizing and positioning constraints.
    private var activeConstraints: [NSLayoutConstraint] = []

    /// Installs constraints to position the toast either centered or above bottom.
    func updateLayoutConstraints(context: LayoutContext, layoutGuide: LayoutGuide) {
        let container = context.containerView
        let presentedView = context.presentedView

        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints.removeAll()

        presentedView.translatesAutoresizingMaskIntoConstraints = false

        // Sizing: width flexible by default to fit within safe area minus insets
        switch layoutGuide.width {
        case let .fixed(value):
            let w = max(0, value - (layoutGuide.contentInsets.left + layoutGuide.contentInsets.right))
            activeConstraints.append(presentedView.widthAnchor.constraint(equalToConstant: w))
        case .flexible:
            let safeInsets = container.safeAreaInsets
            let leftSafe = layoutGuide.edgesForExtendedSafeArea.contains(.left) ? 0 : safeInsets.left
            let rightSafe = layoutGuide.edgesForExtendedSafeArea.contains(.right) ? 0 : safeInsets.right
            let available = max(0, container.bounds.width - leftSafe - rightSafe - layoutGuide.contentInsets.left - layoutGuide.contentInsets.right)
            activeConstraints.append(presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: available))
        case let .fractional(f):
            let insetSum = layoutGuide.contentInsets.left + layoutGuide.contentInsets.right
            let c = -insetSum
            activeConstraints.append(presentedView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: max(0, f), constant: c))
        }

        switch layoutGuide.height {
        case let .fixed(value):
            let h = max(0, value - (layoutGuide.contentInsets.top + layoutGuide.contentInsets.bottom))
            activeConstraints.append(presentedView.heightAnchor.constraint(equalToConstant: h))
        case .flexible:
            let safeInsets = container.safeAreaInsets
            let topSafe = layoutGuide.edgesForExtendedSafeArea.contains(.top) ? 0 : safeInsets.top
            let bottomSafe = layoutGuide.edgesForExtendedSafeArea.contains(.bottom) ? 0 : safeInsets.bottom
            let available = max(0, container.bounds.height - topSafe - bottomSafe - layoutGuide.contentInsets.top - layoutGuide.contentInsets.bottom)
            activeConstraints.append(presentedView.heightAnchor.constraint(lessThanOrEqualToConstant: available))
        case let .fractional(f):
            let insetSum = layoutGuide.contentInsets.top + layoutGuide.contentInsets.bottom
            let c = -insetSum
            activeConstraints.append(presentedView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: max(0, f), constant: c))
        }

        // Center X
        activeConstraints.append(presentedView.centerXAnchor.constraint(equalTo: container.centerXAnchor))

        // Vertical position
        switch position {
        case .center:
            activeConstraints.append(presentedView.centerYAnchor.constraint(equalTo: container.centerYAnchor))
        case .bottom:
            let bottomOffset = container.bounds.height * 0.15
            let bottomAnchor = layoutGuide.edgesForExtendedSafeArea.contains(.bottom) ? container.bottomAnchor : container.safeAreaLayoutGuide.bottomAnchor
            activeConstraints.append(presentedView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(bottomOffset + layoutGuide.contentInsets.bottom)))
        }

        NSLayoutConstraint.activate(activeConstraints)
    }
}
