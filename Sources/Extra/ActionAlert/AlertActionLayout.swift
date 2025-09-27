//
//  AlertActionLayout.swift
//  EasyAlert
//
//  Created by iya on 2022/12/4.
//

import UIKit

/// A layout implementation that arranges action buttons in a stack view.
///
/// `AlertActionLayout` provides a standard layout for action buttons using a `UIStackView`.
/// It supports both horizontal and vertical arrangements based on the number of actions,
/// with proper separators between buttons.
internal struct AlertActionLayout: ActionLayout {

    /// A Boolean value that determines whether separators between actions should be hidden.
    ///
    /// This layout always shows separators between action buttons for visual clarity.
    var prefersSeparatorHidden: Bool { false }

    /// The stack view that manages the arrangement of action buttons.
    private let stackView: UIStackView

    /// An array of active layout constraints for the stack view and separators.
    private var constraints: [NSLayoutConstraint] = []

    /// Creates a new alert action layout with default configuration.
    ///
    /// This initializer sets up the stack view with equal distribution and
    /// appropriate spacing for action buttons.
    init() {
        stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 1 / UIScreen.main.scale
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Lays out the specified views within the given container.
    ///
    /// This method arranges the action button views in a stack view with appropriate
    /// separators. For 2 or fewer actions, buttons are arranged horizontally with
    /// a vertical separator. For more than 2 actions, buttons are arranged vertically
    /// with horizontal separators between them.
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
        stackView.axis = views.count <= 2 ? .horizontal : .vertical
        container.addSubview(stackView)

        constraints.append(stackView.topAnchor.constraint(equalTo: container.topAnchor))
        constraints.append(stackView.leftAnchor.constraint(equalTo: container.leftAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor))
        constraints.append(stackView.rightAnchor.constraint(equalTo: container.rightAnchor))

        if views.count == 2 {
            let separator = container.verticalSeparator(at: 0)
            stackView.addSubview(separator)
            constraints.append(separator.topAnchor.constraint(equalTo: stackView.topAnchor))
            constraints.append(separator.bottomAnchor.constraint(equalTo: stackView.bottomAnchor))
            constraints.append(separator.centerXAnchor.constraint(equalTo: stackView.centerXAnchor))
            constraints.append(separator.widthAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale))
        } else {
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
}
