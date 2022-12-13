//
//  BackgroundProvider.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/8/8.
//

import UIKit

public enum Dimming {
    case color(UIColor)
    case view(UIView)
    case blur(UIBlurEffect.Style, level: Float = 0.5, color: UIColor? = nil)
}

public protocol BackgroundProvider {
    
    /// 背景调光层
    var dimming: Dimming { get set }
    
    /// 是否允许点击背景层隐藏 alert
    var allowDismissWhenBackgroundTouch: Bool { get set }
}

struct DefaultBackgroundProvider: BackgroundProvider {
    
   var dimming: Dimming = .color(Self.alertDimmingViewColor)
   
   var allowDismissWhenBackgroundTouch: Bool = false
}

extension DefaultBackgroundProvider {
    
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
