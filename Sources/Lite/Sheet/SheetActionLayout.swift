//
//  SheetActionLayout.swift
//  EasyAlert
//
//  Created by iya on 2022/12/6.
//

import UIKit

/// A layout implementation that arranges action buttons vertically in a stack view for action sheets.
///
/// `SheetActionLayout` provides a vertical layout for action buttons using a `UIStackView`.
/// It's specifically designed for action sheets where actions are displayed in a vertical list
/// with proper separators between buttons for visual clarity.
internal struct SheetActionLayout: ActionLayout {

    /// A Boolean value that determines whether separators between actions should be hidden.
    ///
    /// This layout always shows separators between action buttons for visual clarity
    /// and proper visual separation in action sheets.
    var prefersSeparatorHidden: Bool { false }

    /// The stack view that manages the vertical arrangement of action buttons.
    ///
    /// This stack view is configured for vertical layout with equal distribution
    /// and appropriate spacing for action sheet presentation.
    private let stackView: UIStackView

    /// An array of active layout constraints for the stack view and separators.
    ///
    /// This property stores the constraints that position and size the stack view
    /// and its separators, allowing for proper constraint management and updates.
    private var constraints: [NSLayoutConstraint] = []

    /// Creates a new sheet action layout with default configuration.
    ///
    /// This initializer sets up the stack view with vertical axis, equal distribution,
    /// and appropriate spacing for action sheet buttons.
    init() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 1 / UIScreen.main.scale
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Lays out the specified views within the given container.
    ///
    /// This method arranges the action button views in a vertical stack view with appropriate
    /// separators between them. It's specifically designed for action sheets where actions
    /// are displayed in a vertical list with proper visual separation.
    ///
    /// - Parameters:
    ///   - views: An array of views representing the action buttons to be laid out.
    ///   - container: The container view that will hold the action button views.
    mutating func layout(views: [UIView], container: UIView) {

        guard let container = container as? ActionSeparatableSequenceView else {
            return
        }

        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        defer { NSLayoutConstraint.activate(constraints) }

        stackView.subviews.forEach { $0.removeFromSuperview() }
        views.forEach { stackView.addArrangedSubview($0) }
        container.addSubview(stackView)

        constraints.append(stackView.topAnchor.constraint(equalTo: container.topAnchor))
        constraints.append(stackView.leftAnchor.constraint(equalTo: container.leftAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor))
        constraints.append(stackView.rightAnchor.constraint(equalTo: container.rightAnchor))

        views.enumerated().forEach { (idx, button) in
            if idx == 0 { return }
            let separator = container.horizontalSeparator(at: idx - 1)
            stackView.addSubview(separator)
            constraints.append(separator.topAnchor.constraint(equalTo: button.topAnchor, constant: -stackView.spacing))
            constraints.append(separator.leftAnchor.constraint(equalTo: stackView.leftAnchor))
            constraints.append(separator.rightAnchor.constraint(equalTo: stackView.rightAnchor))
            constraints.append(separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale))
        }
    }
}
