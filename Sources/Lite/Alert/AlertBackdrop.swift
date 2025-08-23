//
//  AlertBackdrop.swift
//  EasyAlert
//
//  Created by iya on 2021/8/8.
//

import UIKit

/// This enum defines the different types of backdrops that can be used with an alert.
public enum Dimming: Sendable {
    
    public enum BlurEffectStyle: Sendable {
        case regular
        case dark
    }
    
    /// A solid color can be used as the backdrop, with an optional alpha channel.
    case color(UIColor)
    
    /// An optional custom view can be used as the backdrop, such as an image or a gradient.
    case view(UIView)
    
    /// The backdrop can be blurred with a Gaussian blur effect, with a specified blur level in the range of 0 to 1.
    case blur(style: BlurEffectStyle, radius: CGFloat = 30)
}

extension Dimming.BlurEffectStyle {
    
    var color: UIColor? {
        switch self {
        case .regular: return nil
        case .dark: return UIColor.black.withAlphaComponent(0.5)
        }
    }
}

/// This enum defines the different penetration scopes for the backdrop.
/// It specifies if clicking on the backdrop should allow click events to penetrate to the view below.
public enum BackdropInteractionScope: Sendable {
    
    /// No penetration is allowed.
    case none
    
    /// Only click events for the backdrop itself are allowed to penetrate.
    case dimming
    
    /// All click events can penetrate, making the alert not interactive.
    case all
}

/// This protocol defines the properties and methods that interact with the alert backdrop.
public protocol AlertBackdrop: Sendable {
    
    /// This property defines the type of backdrop used by the alert.
    var dimming: Dimming { get set }
    
    /// This property determines whether tapping on the backdrop should automatically dismiss the alert.
    var allowDismissWhenBackgroundTouch: Bool { get set }
    
    /// This property specifies the penetration scope for the backdrop.
    var interactionScope: BackdropInteractionScope { get set }
}

/// This struct implements the `AlertBackdropProvider` protocol with default values.
@MainActor struct DefaultAlertBackdropProvider: AlertBackdrop {
    
    /// This property sets the default type of backdrop to be a semi-transparent black color.
    var dimming: Dimming = .color(Self.alertDimmingViewColor)
    
    /// This property is set to `false` by default, which means tapping on the backdrop does not dismiss the alert.
    var allowDismissWhenBackgroundTouch: Bool = false
    
    /// This property is set to `none` by default, which means clicking on the backdrop does not allow any events to penetrate.
    var interactionScope: BackdropInteractionScope = .none
}

extension DefaultAlertBackdropProvider {
    
    /// This method returns the color for the semi-transparent black backdrop view used in alerts.
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
