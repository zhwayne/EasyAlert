//
//  ActionAlertble.swift
//  EasyAlert
//
//  Created by iya on 2022/12/4.
//

import Foundation

@MainActor public protocol ActionAlertble: Alertble {
    
    func addAction(_ action: Action)
}

public extension ActionAlertble {
    
    func addActions(_ actions: [Action]) {
        actions.forEach { addAction($0) }
    }
}

@MainActor protocol _ActionAlertble: ActionAlertble {
    
    var actions: [Action] { get }
}

extension _ActionAlertble {
    
    func canAddAction(_ action: Action) -> Bool {
#if DEBUG
        assert(!isActive, "\(self) can only add one action if is not display.`")
        assert(!isDuplicateCancelAction(action), "\(self) can only have one action with a style of `Action.Style.cancel`.")
#endif
        return !isActive && !isDuplicateCancelAction(action)
    }
    
    func isDuplicateCancelAction(_ action: Action) -> Bool {
        guard action.style == .cancel else { return false }
        return actions.contains { $0.style == .cancel }
    }
    
    var cancelActionIndex: Int? {
        return actions.firstIndex(where: { $0.style == .cancel })
    }
}
