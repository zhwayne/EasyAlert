//
//  ActionSheetCancelBackgroundView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/8.
//

import UIKit

/// A background view specifically designed for cancel actions in action sheets.
///
/// `ActionSheetCancelBackgroundView` provides a specialized background view that
/// uses the system's secondary grouped background color to visually distinguish
/// cancel actions from regular actions in action sheets.
class ActionSheetCancelBackgroundView: UIView {

    /// Creates a new cancel background view with the specified frame.
    ///
    /// This initializer sets up the background view with the appropriate system
    /// background color to provide visual distinction for cancel actions.
    ///
    /// - Parameter frame: The frame rectangle for the view.
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .secondarySystemGroupedBackground
    }

    /// This initializer is not supported and will cause a fatal error.
    ///
    /// - Parameter coder: The NSCoder instance (unused).
    /// - Returns: This method always calls `fatalError`.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
