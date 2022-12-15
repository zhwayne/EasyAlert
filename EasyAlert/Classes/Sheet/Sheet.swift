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
    
    public override init(customView: Alert.CustomizedView) {
        super.init(customView: customView)
        self.transitionCoordinator = SheetTransitionCoordinator(sheet: self)
        backdropProvider.allowDismissWhenBackgroundTouch = true
    }
}
