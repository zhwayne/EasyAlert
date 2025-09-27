//
//  ActionAlertable.swift
//  EasyAlert
//
//  Created by iya on 2022/12/4.
//

import Foundation

/// A protocol that defines the interface for alerts that support action buttons.
///
/// `ActionAlertable` extends the base `Alertable` protocol to provide functionality
/// for managing action buttons within alerts. It defines the core interface for
/// adding and managing actions in alert implementations.
@MainActor public protocol ActionAlertable: Alertable {

    /// The array of actions available in this alert.
    ///
    /// This property provides access to all actions that have been added to the alert.
    var actions: [Action] { get }

    /// Adds an action to the alert.
    ///
    /// This method adds a new action to the alert, with proper validation and ordering.
    /// Cancel actions are automatically positioned according to platform conventions.
    ///
    /// - Parameter action: The action to add to the alert.
    func addAction(_ action: Action)
}

/// A default implementation that provides convenience methods for action management.
///
/// This extension provides utility methods that can be used by any type conforming
/// to `ActionAlertable`, reducing the implementation burden for common operations.
public extension ActionAlertable {

    /// Adds multiple actions to the alert.
    ///
    /// This method provides a convenient way to add multiple actions at once,
    /// delegating to the individual `addAction(_:)` method for each action.
    ///
    /// - Parameter actions: An array of actions to add to the alert.
    func addActions(_ actions: [Action]) {
        actions.forEach { addAction($0) }
    }
}

/// An extension that provides validation and utility methods for action management.
///
/// This extension includes methods for validating action additions and managing
/// cancel actions, ensuring proper behavior and preventing invalid configurations.
extension ActionAlertable {

    /// Determines whether the specified action can be added to the alert.
    ///
    /// This method validates that the alert is not currently active and that
    /// the action doesn't create a duplicate cancel action. In debug builds,
    /// it also provides assertions for common configuration errors.
    ///
    /// - Parameter action: The action to validate for addition.
    /// - Returns: `true` if the action can be added, otherwise `false`.
    func canAddAction(_ action: Action) -> Bool {
#if DEBUG
        assert(!isActive, "\(self) can only add one action if is not display.`")
        assert(!isDuplicateCancelAction(action), "\(self) can only have one action with a style of `Action.Style.cancel`.")
#endif
        return !isActive && !isDuplicateCancelAction(action)
    }

    /// Determines whether the specified action would create a duplicate cancel action.
    ///
    /// This method checks if adding the action would result in multiple cancel actions,
    /// which is not allowed in the alert system.
    ///
    /// - Parameter action: The action to check for duplication.
    /// - Returns: `true` if the action would create a duplicate cancel action, otherwise `false`.
    func isDuplicateCancelAction(_ action: Action) -> Bool {
        guard action.style == .cancel else { return false }
        return actions.contains { $0.style == .cancel }
    }

    /// The index of the cancel action in the actions array.
    ///
    /// This property provides the index of the first cancel action in the actions array,
    /// or `nil` if no cancel action is present.
    ///
    /// - Returns: The index of the cancel action, or `nil` if no cancel action exists.
    var cancelActionIndex: Int? {
        return actions.firstIndex(where: { $0.style == .cancel })
    }
}
