//
//  Sheet.swift
//  EasyAlert
//
//  Created by iya on 2021/12/13.
//

import UIKit

open class Sheet: Alert {
    
    public override init(content: AlertCustomizable) {
        super.init(content: content)
        self.transitionAniamtor = SheetTransitionAnimator()
        self.layoutModifier = SheetLayoutModifier()
        backdropProvider.allowDismissWhenBackgroundTouch = true
        layoutGuide = LayoutGuide(width: .multiplied(by: 1, maxWidth: 414), height: .flexible)
    }
}
