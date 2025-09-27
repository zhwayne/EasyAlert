//
//  ActionRepresentationSequenceView.swift
//  EasyAlert
//
//  Created by iya on 2021/12/17.
//

import UIKit

/// A view that manages the sequence of action representations within an alert.
///
/// `ActionRepresentationSequenceView` serves as a container for action button
/// representations, providing a structured way to display and manage multiple
/// actions in a consistent layout. It delegates the actual layout management
/// to a separatable sequence view.
final class ActionRepresentationSequenceView: UIView {

    /// The separatable sequence view that handles the actual layout of action representations.
    ///
    /// This view is responsible for positioning and arranging the individual action
    /// button representations with proper separators and spacing.
    let separatableSequenceView = ActionSeparatableSequenceView()

    /// Creates a new action representation sequence view with the specified frame.
    ///
    /// This initializer sets up the view with the separatable sequence view as a child,
    /// configuring it to fill the entire bounds and handle user interactions appropriately.
    ///
    /// - Parameter frame: The initial frame for the view.
    override init(frame: CGRect) {
        super.init(frame: frame)
        separatableSequenceView.frame = bounds
        separatableSequenceView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(separatableSequenceView)
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
    }

    /// This initializer is not supported and will cause a fatal error.
    ///
    /// - Parameter coder: The NSCoder instance (unused).
    /// - Returns: This method always calls `fatalError`.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
