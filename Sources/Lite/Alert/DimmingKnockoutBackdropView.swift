//
//  DimmingKnockoutBackdropView.swift
//  EasyAlert
//
//  Created by iya on 2021/7/27.
//

import UIKit

/**
 A view used for dimming or knocking out content behind it.

 This view can be used as a backdrop view for popups or alerts. It can be used to dim the content behind it or to knockout the content so that only the popup or alert is visible.

 This view provides a hit test method that can be customized by setting the `hitTest` property to a closure that takes a view and a point and returns a boolean indicating whether the view should be excluded from hit testing at the given point.

 The `willRemoveFromSuperviewObserver` property can be set to a closure that will be called when the view is about to be removed from its superview.
 */
final class DimmingKnockoutBackdropView: UIView {

    /// A closure to be called when the view is about to be removed from its superview.
    var willRemoveFromSuperviewObserver: (() -> Void)?

    /// A closure that can be set to customize the hit test behavior of the view.
    var hitTest: ((UIView, CGPoint) -> Bool)?

    /**
     Called just before the view is added to a new superview. If the new superview is `nil`, this method calls the `willRemoveFromSuperviewObserver` closure, if set.
     */
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            willRemoveFromSuperviewObserver?()
        }
    }

    /**
     Initializes and returns a new `DimmingKnockoutBackdropView` instance.

     - Parameter frame: The frame rectangle for the view.
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Returns the farthest descendant of the view in the view hierarchy that contains a specified point.

     If a `hitTest` closure is set and it returns `true` for this view, this method returns `nil` to exclude the view from hit testing at the given point.

     - Parameters:
     - point: A point specified in the receiver's local coordinate system (bounds).
     - event: The event that warranted a call to this method. This parameter is unused.
     - Returns: The view object that is the farthest descendant of the receiver in the view hierarchy (including itself) that contains the specified point. If the point lies outside the receiver's bounds, this method returns `nil`.
     */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let returnsNil = hitTest?(self, point), returnsNil == true {
            return nil
        }
        return super.hitTest(point, with: event)
    }
}
