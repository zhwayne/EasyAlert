//
//  ActionAlertble.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/4.
//

import Foundation

public protocol ActionAlertble: Alertble {
    
    func addAction(_ action: Action)
}

public extension ActionAlertble {
    
    func addActions(_ actions: [Action]) {
        actions.forEach { addAction($0) }
    }
}

protocol ActionAddable: ActionAlertble {
    
    var actions: [Action] { get }
}

extension ActionAddable where Self: Alertble {
    
    func canAddAction(_ action: Action) -> Bool {
#if DEBUG
        assert(!isShowing)
        assert(!isDuplicateCancelAction(action))
#endif
        return !isShowing && !isDuplicateCancelAction(action)
    }
    
    func isDuplicateCancelAction(_ action: Action) -> Bool {
        guard action.style == .cancel else { return false }
        return actions.contains { $0.style == .cancel }
    }
}
