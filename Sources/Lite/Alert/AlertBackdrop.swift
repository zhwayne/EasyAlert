//
//  AlertBackdrop.swift
//  EasyAlert
//
//  Created by iya on 2021/8/8.
//

import UIKit

/// An enum that defines the different types of backdrops that can be used with an alert.
///
/// `Dimming` provides various options for customizing the visual appearance of the alert's background,
/// including solid colors, custom views, and blur effects.
@MainActor public enum Dimming {

    /// The style of blur effect to apply to the backdrop.
    public enum BlurEffectStyle {
        /// A regular blur effect with no color tint.
        case regular
        
        /// A dark blur effect with a dark color tint.
        case dark
    }

    /// A solid color backdrop with an optional alpha channel.
    ///
    /// - Parameter color: The color to use for the backdrop.
    case color(UIColor)

    /// A custom view backdrop, such as an image or gradient.
    ///
    /// - Parameter view: The custom view to use as the backdrop.
    case view(UIView)

    /// A blurred backdrop with a Gaussian blur effect.
    ///
    /// - Parameters:
    ///   - style: The style of blur effect to apply.
    ///   - radius: The blur radius in points. Defaults to 30.
    case blur(style: BlurEffectStyle, radius: CGFloat = 30)
}

extension Dimming.BlurEffectStyle {

    /// The color tint associated with the blur effect style.
    var color: UIColor? {
        switch self {
        case .regular: return nil
        case .dark: return UIColor.black.withAlphaComponent(0.5)
        }
    }
}

/// An enum that defines the different penetration scopes for the backdrop.
///
/// `BackdropInteractionScope` specifies whether and how user interactions with the backdrop
/// should be handled, including whether events should penetrate to views below the alert.
@MainActor public enum BackdropInteractionScope {

    /// No interaction penetration is allowed.
    ///
    /// All touch events are captured by the backdrop and do not reach views below.
    case none

    /// Only touch events on the backdrop itself are allowed to penetrate.
    ///
    /// Touch events on the alert content are captured, but backdrop touches may pass through.
    case dimming

    /// All touch events can penetrate, making the alert non-interactive.
    ///
    /// This effectively makes the alert a visual overlay that doesn't block user interaction.
    case all
}

/// A protocol that defines the properties and methods for interacting with the alert backdrop.
///
/// `AlertBackdrop` provides the interface for customizing the visual appearance and interaction
/// behavior of the alert's background area.
@MainActor public protocol AlertBackdrop {

    /// The type of backdrop used by the alert.
    var dimming: Dimming { get set }

    /// A Boolean value that determines whether tapping on the backdrop should automatically dismiss the alert.
    var allowDismissWhenBackgroundTouch: Bool { get set }

    /// The interaction scope that defines how touch events are handled by the backdrop.
    var interactionScope: BackdropInteractionScope { get set }
}

/// A default implementation of the `AlertBackdrop` protocol with standard values.
///
/// `DefaultAlertBackdropProvider` provides sensible defaults for alert backdrops,
/// including a semi-transparent black background and standard interaction behavior.
@MainActor struct DefaultAlertBackdropProvider: AlertBackdrop {

    /// The default backdrop type, which is a semi-transparent black color.
    var dimming: Dimming = .color(Self.alertDimmingViewColor)

    /// A Boolean value that determines whether tapping the backdrop dismisses the alert.
    ///
    /// Defaults to `false`, meaning tapping the backdrop does not dismiss the alert.
    var allowDismissWhenBackgroundTouch: Bool = false

    /// The default interaction scope for the backdrop.
    ///
    /// Defaults to `.none`, meaning no touch events penetrate through the backdrop.
    var interactionScope: BackdropInteractionScope = .none
}

extension DefaultAlertBackdropProvider {

    /// Returns the default color for the alert dimming view.
    ///
    /// The color adapts to the current interface style, providing appropriate
    /// transparency for both light and dark modes.
    static var alertDimmingViewColor: UIColor {
        return UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(white: 0, alpha: 0.48)
            } else {
                return UIColor(white: 0, alpha: 0.2)
            }
        }
    }
}
