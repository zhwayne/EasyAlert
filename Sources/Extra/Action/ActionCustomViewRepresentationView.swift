//
//  ActionCustomViewRepresentationView.swift
//  EasyAlert
//
//  Created by iya on 2021/8/2.
//

import UIKit

/// A control that represents a custom action view within an alert.
///
/// `ActionCustomViewRepresentationView` serves as a wrapper for custom action views,
/// providing touch handling, highlighting, and visual feedback. It manages the
/// display of custom action content and handles user interactions appropriately.
final class ActionCustomViewRepresentationView: UIControl, RepresentationMark {

    /// The action that this representation view displays.
    ///
    /// When set, this property automatically manages the display of the action's
    /// custom view, removing any previous view and adding the new one.
    var action: Action? {
        didSet {
            oldValue?.view?.removeFromSuperview()
            if let view = action?.view {
                addSubview(view)
            }
        }
    }

    /// A Boolean value that determines whether the action is currently highlighted.
    ///
    /// When set, this property updates the action's view highlighting state and
    /// manages the visibility of adjacent separators to provide visual feedback
    /// during user interaction.
    override var isHighlighted: Bool {
        didSet {
            action?.view?.isHighlighted = isHighlighted
            // 寻找相邻的 separators
            var separatableSequenceView: ActionSeparatableSequenceView?
            for view in sequence(first: superview, next: { $0?.superview }) {
                if let view = view as? ActionSeparatableSequenceView {
                    separatableSequenceView = view
                    break
                }
            }
            guard let target = separatableSequenceView,
                  let separators = target.findSubviews(ofType: ActionVibrantSeparatorView.self) else {
                return
            }

            separators.filter({ separator in
                let frame1 = target.convert(frame.insetBy(dx: -1, dy: -1), from: self.superview!)
                let frame2 = target.convert(separator.frame, from: separator.superview!)
                return frame1.intersects(frame2)
            }).forEach { separator in
                separator.alpha = isHighlighted ? 0 : 1
            }
        }
    }

    /// A Boolean value that determines whether the action is enabled.
    ///
    /// When set, this property updates the action's view enabled state,
    /// affecting both the visual appearance and user interaction capabilities.
    override var isEnabled: Bool {
        didSet {
            action?.view?.isEnabled = isEnabled
        }
    }

    /// Creates a new action custom view representation with the specified frame.
    ///
    /// This initializer sets up the view with proper clipping to ensure
    /// that the custom action content is displayed correctly.
    ///
    /// - Parameter frame: The initial frame for the view.
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }

    /// This initializer is not supported and will cause a fatal error.
    ///
    /// - Parameter coder: The NSCoder instance (unused).
    /// - Returns: This method always calls `fatalError`.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Returns the intrinsic content size of the action's view.
    ///
    /// This method delegates to the action's view to determine the appropriate
    /// size for the representation view.
    ///
    /// - Returns: The intrinsic content size of the action's view, or zero if no action is set.
    override var intrinsicContentSize: CGSize {
        return action?.view?.intrinsicContentSize ?? .zero
    }

    /// Updates the layout of the action's view within this representation view.
    ///
    /// This method ensures that the action's view fills the entire bounds
    /// of this representation view, providing proper display of the custom content.
    override func layoutSubviews() {
        super.layoutSubviews()

        if let action, let view = action.view {
            view.frame = bounds
        }
    }
}
