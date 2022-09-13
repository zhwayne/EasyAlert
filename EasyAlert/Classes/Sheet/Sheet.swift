//
//  Sheet.swift
//  EasyAlert
//
//  Created by iya on 2021/12/13.
//

import Foundation

open class Sheet: Alert {
    
    public override init(customView: Alert.CustomizedView) {
        super.init(customView: customView)
        self.transitionCoordinator = SheetTransitionCoordinator()
    }
}
