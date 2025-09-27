//
//  ActionAlertActionView.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

/// An extension that provides action view implementation for action alerts.
///
/// This extension defines the `ActionView` class that provides the visual representation
/// for action buttons in action alerts, including proper styling and interaction handling.
extension ActionAlert {

    /// A view that represents an action button within an action alert.
    ///
    /// `ActionView` provides the visual representation for action buttons, including
    /// title display, highlighting, and enabled/disabled states. It conforms to
    /// `ActionContent` to integrate with the action system.
    @MainActor final class ActionView: UIView, ActionContent {

        /// The title text displayed on the action button.
        ///
        /// This property provides access to the button's title text, which is
        /// displayed in the center of the action view.
        var title: String? {
            get { titleLabel.text }
            set { titleLabel.text = newValue }
        }

        /// A Boolean value that determines whether the action is currently highlighted.
        ///
        /// When set, this property updates the visual appearance of the action view
        /// to indicate the highlighted state, typically during user interaction.
        var isHighlighted: Bool = false {
            didSet {
                highlightedOverlay.alpha = isHighlighted ? 1 : 0
            }
        }

        /// The visual style of the action.
        ///
        /// This property determines the appearance and behavior of the action button,
        /// including color, font, and other visual characteristics.
        let style: Action.Style

        /// A Boolean value that determines whether the action is enabled.
        ///
        /// When set, this property updates the visual appearance of the action view
        /// to indicate the enabled/disabled state, affecting user interaction.
        var isEnabled: Bool = true {
            didSet {
                highlightedOverlay.alpha = isEnabled ? 0 : 1
            }
        }

        /// A view that provides visual feedback during highlighting.
        ///
        /// This overlay view is displayed when the action is highlighted, providing
        /// visual feedback to the user during interaction.
        private let highlightedOverlay: UIView = {
            let view = UIView()
            view.backgroundColor = .systemFill
            view.alpha = 0
            view.isUserInteractionEnabled = false
            return view
        }()

        /// The label that displays the action's title text.
        ///
        /// This label is configured with the appropriate font and color based on
        /// the action's style, providing the visual representation of the action.
        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.font = font(for: style)
            label.textAlignment = .center
            label.textColor = color(for: style)
            return label
        }()

        /// Creates a new action view with the specified style.
        ///
        /// This initializer sets up the action view with the provided style,
        /// configuring the visual appearance and layout appropriately.
        ///
        /// - Parameter style: The visual style of the action.
        required init(style: Action.Style) {
            self.style = style
            super.init(frame: .zero)

            clipsToBounds = true
            addSubview(highlightedOverlay)
            addSubview(titleLabel)

            highlightedOverlay.frame = bounds
            highlightedOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            titleLabel.frame = bounds
            titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }

        /// This initializer is not supported and will cause a fatal error.
        ///
        /// - Parameter frame: The frame for the view (unused).
        /// - Returns: This method always calls `fatalError`.
        @available(*, unavailable)
        override init(frame: CGRect) {
            fatalError("using init(style:) instead.")
        }

        /// This initializer is not supported and will cause a fatal error.
        ///
        /// - Parameter coder: The NSCoder instance (unused).
        /// - Returns: This method always calls `fatalError`.
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /// Returns the intrinsic content size for the action view.
        ///
        /// This method provides the appropriate size for the action view, with a
        /// standard height of 44 points to match platform conventions.
        ///
        /// - Returns: The intrinsic content size for the action view.
        override var intrinsicContentSize: CGSize {
            var size = super.intrinsicContentSize
            size.height = 44
            return size
        }
    }
}

/// A private extension that provides styling methods for action views.
///
/// This extension includes methods for determining the appropriate color and font
/// for action views based on their style, ensuring consistent visual presentation.
fileprivate extension ActionAlert.ActionView {

    /// Returns the appropriate color for the specified action style.
    ///
    /// This method provides the standard color for each action style, following
    /// platform conventions for visual hierarchy and user experience.
    ///
    /// - Parameter style: The action style to get the color for.
    /// - Returns: The appropriate color for the action style.
    func color(for style: Action.Style) -> UIColor {
        switch style {
        case .`default`: return .systemBlue
        case .cancel: return .systemBlue
        case .destructive: return .systemRed
        }
    }

    /// Returns the appropriate font for the specified action style.
    ///
    /// This method provides the standard font for each action style, ensuring
    /// proper typography and visual hierarchy.
    ///
    /// - Parameter style: The action style to get the font for.
    /// - Returns: The appropriate font for the action style.
    func font(for style: Action.Style) -> UIFont {
        switch style {
        case .`default`: return .systemFont(ofSize: 17, weight: .regular)
        case .cancel: return .systemFont(ofSize: 17, weight: .semibold)
        case .destructive: return .systemFont(ofSize: 17, weight: .regular)
        }
    }
}
