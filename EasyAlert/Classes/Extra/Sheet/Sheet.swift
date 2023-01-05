//
//  Sheet.swift
//  EasyAlert
//
//  Created by iya on 2021/12/13.
//

import Foundation

open class Sheet: Alert {
    
    /// The content will not extend beyond the bottom safe area if `ignoreBottomSafeArea` is set to `true`.
    public var ignoreBottomSafeArea: Bool = false
    
    public override init<T>(customizable: T) where T : AlertCustomizable {
        super.init(customizable: customizable)
        self.transitionAniamtor = SheetTransitionAnimator(sheet: self)
        backdropProvider.allowDismissWhenBackgroundTouch = true
        layoutGuide = LayoutGuide(width: .multiplied(1, maximumWidth: 414))
    }
}
