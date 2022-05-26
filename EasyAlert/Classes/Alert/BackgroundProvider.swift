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
}

public protocol BackgroundProvider {
    
    /// 背景调光层
    var dimming: Dimming { get set }
    
    /// 是否允许点击背景层隐藏 alert
    var allowDismissWhenBackgroundTouch: Bool { get set }
}

public struct DefaultBackgroundProvider: BackgroundProvider {
    
    public var dimming: Dimming = .color(.black.withAlphaComponent(0.25))
    
    public var allowDismissWhenBackgroundTouch: Bool = false
}
