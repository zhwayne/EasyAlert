//
//  Sheet.swift
//  EasyAlert
//
//  Created by iya on 2021/12/13.
//

import UIKit

open class Sheet: Alert {
    
    /// The content will not extend beyond the bottom safe area if `ignoreBottomSafeArea` is set to `true`.
    public var ignoreBottomSafeArea: Bool = false
    
    public override init(content: AlertCustomizable) {
        super.init(content: content)
        self.transitionAniamtor = SheetTransitionAnimator()
        self.layoutModifier = SheetLayoutModifier(sheet: self)
        backdropProvider.allowDismissWhenBackgroundTouch = true
        layoutGuide = LayoutGuide(width: .multiplied(by: 1, maximumWidth: 414))
    }
}
