//
//  BackdropProvider.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/8/8.
//

import UIKit

/// This enum defines the different types of backdrops that can be used with an alert.
public enum Dimming {
    
    /// A solid color can be used as the backdrop, with an optional alpha channel.
    case color(UIColor)
    
    /// An optional custom view can be used as the backdrop, such as an image or a gradient.
    case view(UIView)
    
    /// The backdrop can be blurred with a Gaussian blur effect, with a specified blur level in the range of 0 to 1.
    case blur(style: UIBlurEffect.Style, level: Float = 0.5)
    
    func makeUIView() -> UIView {
        let uiView: UIView
        switch self {
        case let .color(color):
            uiView = UIView()
            uiView.backgroundColor = color
        case let .view(view):
            uiView = view
        case let .blur(style, level):
            uiView = BlurEffectView(effect: UIBlurEffect(style: style), intensity: level)
        }
        return uiView
    }
}

/// This enum defines the different penetration scopes for the backdrop.
/// It specifies if clicking on the backdrop should allow click events to penetrate to the view below.
public enum PenetrationScope {
    
    /// No penetration is allowed.
    case none
    
    /// Only click events for the backdrop itself are allowed to penetrate.
    case dimming
    
    /// All click events can penetrate, making the alert not interactive.
    case all
}

/// This protocol defines the properties and methods that interact with the alert backdrop.
public protocol BackdropProvider {
    
    /// This property defines the type of backdrop used by the alert.
    var dimming: Dimming { get set }
    
    /// This property determines whether tapping on the backdrop should automatically dismiss the alert.
    var allowDismissWhenBackgroundTouch: Bool { get set }
    
    /// This property specifies the penetration scope for the backdrop.
    var penetrationScope: PenetrationScope { get set }
}

/// This struct implements the `BackdropProvider` protocol with default values.
struct DefaultBackdropProvider: BackdropProvider {
    
    /// This property sets the default type of backdrop to be a semi-transparent black color.
    var dimming: Dimming = .color(Self.alertDimmingViewColor)
    
    /// This property is set to `false` by default, which means tapping on the backdrop does not dismiss the alert.
    var allowDismissWhenBackgroundTouch: Bool = false
    
    /// This property is set to `none` by default, which means clicking on the backdrop does not allow any events to penetrate.
    var penetrationScope: PenetrationScope = .none
}

extension DefaultBackdropProvider {
    
    /// This method returns the color for the semi-transparent black backdrop view used in alerts.
    static var alertDimmingViewColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(white: 0, alpha: 0.48)
                } else {
                    return UIColor(white: 0, alpha: 0.2)
                }
            }
        } else {
            return UIColor(white: 0, alpha: 0.2)
        }
    }
}
