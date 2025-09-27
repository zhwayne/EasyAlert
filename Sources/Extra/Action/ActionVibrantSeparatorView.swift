//
//  ActionVibrantSeparatorView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import UIKit

/// A view that provides a vibrant separator effect between action buttons.
///
/// `ActionVibrantSeparatorView` creates a visually appealing separator that uses
/// iOS's vibrancy effects to provide a subtle but effective visual separation
/// between action buttons in alerts and action sheets.
class ActionVibrantSeparatorView: UIView {

    /// Creates a new vibrant separator view with the default configuration.
    ///
    /// This initializer sets up the separator view with a vibrancy effect that
    /// provides a subtle visual separation between action buttons. The effect
    /// uses the system material blur style with separator vibrancy for optimal
    /// visual integration with the system UI.
    required init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let blureEffect: UIBlurEffect
        let vibrancyEffect: UIVisualEffect
        blureEffect = UIBlurEffect(style: .systemMaterial)
        vibrancyEffect = UIVibrancyEffect(blurEffect: blureEffect, style: .separator)
        let effectView = UIVisualEffectView(effect: vibrancyEffect)
        effectView.contentView.backgroundColor = .white
        addSubview(effectView)
    }

    /// Updates the layout of the separator view's subviews.
    ///
    /// This method ensures that the vibrancy effect view fills the entire
    /// bounds of the separator view, providing consistent visual separation.
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.first?.frame = bounds
    }

    /// This initializer is not supported and will cause a fatal error.
    ///
    /// - Parameter coder: The NSCoder instance (unused).
    /// - Returns: This method always calls `fatalError`.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
