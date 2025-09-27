//
//  Sheet.swift
//  EasyAlert
//
//  Created by iya on 2021/12/13.
//

import UIKit

/// A base class for sheet presentations that slide up from the bottom of the screen.
///
/// `Sheet` extends the base `Alert` class to provide specialized functionality
/// for sheet presentations. It configures the appropriate animator and layout
/// for slide-up animations and bottom positioning, creating a natural modal
/// presentation experience.
open class Sheet: Alert {

    /// Creates a new sheet with the specified content.
    ///
    /// This initializer sets up the sheet with the provided content and configures
    /// the appropriate animator and layout for sheet presentation. The sheet is
    /// configured with a multiplied width (up to 414 points) and flexible height
    /// to accommodate various content sizes.
    ///
    /// - Parameter content: The content to display in the sheet.
    public override init(content: AlertContent) {
        super.init(content: content)
        self.animator = SheetAnimator()
        self.layout = SheetLayout()
        layoutGuide = .init(width: .multiplied(by: 1, maxWidth: 414), height: .flexible)
    }
}
