//
//  BackdropProvider.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/8/8.
//

import UIKit

/// Defines a layer to fill the backdrop.
public enum Dimming {
    
    /// Fill with color. Color values can have an alpha channel.
    case color(UIColor)
    
    /// Use a custom view to fill the backdrop. For example, you can fill the
    /// backdrop with an image. You just use 'UIImageView'.
    case view(UIView)
    
    /// This is a good option if you want to blur the backdrop when displaying
    /// alert. A gaussian blur effect will appear on the backdrop. You can
    /// specify the blur level in the range [0, 1]. 0.5 by default.
    case blur(style: UIBlurEffect.Style, level: Float = 0.5)
}

/// The scape of penetration. It allows clicking on background events to penetrate
/// to the view below.
public enum PenetrationScope {
    
    /// No penetration allowed.
    case none
    
    /// Allows click events to penetrate the backdrop.
    case dimming
    
    /// Penetrate all click events, i.e. the pop-up no longer allows user interaction.
    case all
}

/// A Provider that interacts with the backdrop.
public protocol BackdropProvider {
    
    /// A layer to fill the background.
    var dimming: Dimming { get set }
    
    /// Automatically dismiss alert when background is clicked if set to `true`.
    var allowDismissWhenBackgroundTouch: Bool { get set }
    
    /// The scape of penetration.
    var penetrationScope: PenetrationScope { get set }
}

struct DefaultBackdropProvider: BackdropProvider {
    
    var dimming: Dimming = .color(Self.alertDimmingViewColor)
   
    var allowDismissWhenBackgroundTouch: Bool = false
    
    var penetrationScope: PenetrationScope = .none
}

extension DefaultBackdropProvider {
    
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
