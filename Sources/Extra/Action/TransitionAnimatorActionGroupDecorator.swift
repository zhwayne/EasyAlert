//
//  TransitionAnimatorActionGroupDecorator.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import Foundation

/// A decorator that combines animation and layout functionality for action group views.
///
/// `ActionGroupAnimatorAndLayoutDecorator` acts as a bridge between the alert system's
/// animation and layout protocols and the action group views. It delegates animation
/// and layout operations to the underlying animator and layout modifier while
/// managing the specific needs of action group views.
final class ActionGroupAnimatorAndLayoutDecorator: AlertbleAnimator, AlertableLayout {

    /// The underlying animator that handles the actual animation logic.
    private var animator: AlertbleAnimator
    
    /// The layout modifier that handles the positioning and sizing of views.
    private var layoutModifier: AlertableLayout
    
    /// The action group views that this decorator manages.
    private var actionGroupViews: [ActionGroupView] = []

    /// Creates a new decorator with the specified animator, layout modifier, and action group views.
    ///
    /// - Parameters:
    ///   - animator: The animator that will handle the animation logic.
    ///   - layoutModifier: The layout modifier that will handle positioning and sizing.
    ///   - actionGroupViews: The action group views to be managed by this decorator.
    init(animator: AlertbleAnimator, layoutModifier: AlertableLayout, actionGroupViews: [ActionGroupView]) {
        self.animator = animator
        self.layoutModifier = layoutModifier
        self.actionGroupViews = actionGroupViews
    }

    /// Updates the layout of the action group views based on the provided context and layout guide.
    ///
    /// This method delegates to the underlying layout modifier and then updates
    /// each action group view with the current interface orientation.
    ///
    /// - Parameters:
    ///   - context: The layout context containing information about the current state.
    ///   - layoutGuide: The layout guide that defines the positioning constraints.
    func updateLayout(context: LayoutContext, layoutGuide: LayoutGuide) {
        layoutModifier.updateLayout(context: context, layoutGuide: layoutGuide)
        actionGroupViews.forEach { view in
            view.updateLayout(interfaceOrientation: context.interfaceOrientation)
        }
    }

    /// Performs the animation for showing the action group views.
    ///
    /// This method delegates to the underlying animator to handle the show animation.
    ///
    /// - Parameters:
    ///   - context: The layout context containing information about the current state.
    ///   - completion: A closure to execute when the animation completes.
    func show(context: LayoutContext, completion: @escaping () -> Void) {
        animator.show(context: context, completion: completion)
    }

    /// Performs the animation for dismissing the action group views.
    ///
    /// This method delegates to the underlying animator to handle the dismiss animation.
    ///
    /// - Parameters:
    ///   - context: The layout context containing information about the current state.
    ///   - completion: A closure to execute when the animation completes.
    func dismiss(context: LayoutContext, completion: @escaping () -> Void) {
        animator.dismiss(context: context, completion: completion)
    }
}
