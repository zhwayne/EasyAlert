//
//  ActionSeparatableSequenceView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/2.
//

import UIKit

/// A view that manages a sequence of action representations with separators.
///
/// `ActionSeparatableSequenceView` provides a container for action button representations
/// with support for both horizontal and vertical separators. It manages the creation
/// and positioning of separators between action buttons to provide visual separation.
final class ActionSeparatableSequenceView: UIView {

    /// An array of horizontal separators used between action buttons.
    private var horizontalSeparators: [ActionVibrantSeparatorView] = []
    
    /// An array of vertical separators used between action buttons.
    private var verticalSeparators: [ActionVibrantSeparatorView] = []

    /// Creates a new separatable sequence view with the specified frame.
    ///
    /// This initializer sets up the view with proper clipping and corner curve
    /// configuration for optimal visual appearance.
    ///
    /// - Parameter frame: The initial frame for the view.
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerCurve = .continuous
    }

    /// This initializer is not supported and will cause a fatal error.
    ///
    /// - Parameter coder: The NSCoder instance (unused).
    /// - Returns: This method always calls `fatalError`.
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets the corner radius for the view with optional corner specification.
    ///
    /// This method applies the specified corner radius to the view, with the option
    /// to specify which corners should be rounded. This is useful for creating
    /// alerts with different corner configurations.
    ///
    /// - Parameters:
    ///   - radius: The corner radius to apply.
    ///   - corners: The corners to apply the radius to. Defaults to all corners.
    func setCornerRadius(_ radius: CGFloat, corners: UIRectCorner = .allCorners) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners.layerMaskedCorners
        layer.cornerCurve = .continuous
    }

    /// Returns the horizontal separator at the specified index.
    ///
    /// This method provides access to horizontal separators, creating new ones
    /// as needed. Horizontal separators are typically used between action buttons
    /// in vertical layouts.
    ///
    /// - Parameter index: The index of the separator to retrieve.
    /// - Returns: The horizontal separator view at the specified index.
    func horizontalSeparator(at index: Int) -> UIView {
        guard index < horizontalSeparators.count else {
            horizontalSeparators.append(ActionVibrantSeparatorView())
            return horizontalSeparator(at: index)
        }
        return horizontalSeparators[index]
    }

    /// Returns the vertical separator at the specified index.
    ///
    /// This method provides access to vertical separators, creating new ones
    /// as needed. Vertical separators are typically used between action buttons
    /// in horizontal layouts.
    ///
    /// - Parameter index: The index of the separator to retrieve.
    /// - Returns: The vertical separator view at the specified index.
    func verticalSeparator(at index: Int) -> UIView {
        guard index < verticalSeparators.count else {
            verticalSeparators.append(ActionVibrantSeparatorView())
            return verticalSeparator(at: index)
        }
        return verticalSeparators[index]
    }
}

/// An extension that provides conversion between `UIRectCorner` and `CACornerMask`.
///
/// This extension enables the conversion of `UIRectCorner` values to their corresponding
/// `CACornerMask` values, which are used by Core Animation for layer corner masking.
extension UIRectCorner {

    /// Converts the `UIRectCorner` value to its corresponding `CACornerMask`.
    ///
    /// This method maps each corner from the `UIRectCorner` enum to its corresponding
    /// `CACornerMask` value, enabling the use of `UIRectCorner` with Core Animation
    /// layer corner masking.
    ///
    /// - Returns: The corresponding `CACornerMask` value for the specified corners.
    var layerMaskedCorners: CACornerMask {
        var mask = CACornerMask(rawValue: 0)
        if contains(.topLeft) { mask.insert(.layerMinXMinYCorner) }
        if contains(.topRight) { mask.insert(.layerMaxXMinYCorner) }
        if contains(.bottomLeft) { mask.insert(.layerMinXMaxYCorner) }
        if contains(.bottomRight) { mask.insert(.layerMaxXMaxYCorner) }
        return mask
    }
}
