//
//  AlertTapTarget.swift
//  EasyAlert
//
//  Created by iya on 2021/7/28.
//

import UIKit

/// A target object that handles tap gestures for alert backdrops.
///
/// `TapTarget` provides a convenient way to handle tap gestures on alert backdrops
/// with customizable behavior. It allows you to specify when tap gestures should
/// begin and what action should be taken when a tap occurs.
final class TapTarget: NSObject, UIGestureRecognizerDelegate {

    /// A closure that determines whether a gesture recognizer should begin.
    ///
    /// This closure is called to determine if the tap gesture should be recognized.
    /// Return `true` to allow the gesture to begin, or `false` to prevent it.
    var gestureRecognizerShouldBeginBlock: ((UIGestureRecognizer) -> Bool)?

    /// A closure that is called when a tap gesture is recognized.
    ///
    /// This closure is executed when the tap gesture is successfully recognized
    /// and the gesture recognizer should begin.
    var tapHandler: (() -> Void)?

    /// The tap gesture recognizer that handles tap events.
    ///
    /// This gesture recognizer is lazily created and configured to call the
    /// `handleTap(_:)` method when a tap is detected.
    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        return tap
    }()

    /// Determines whether a gesture recognizer should begin.
    ///
    /// This method is called by the gesture recognizer to determine if it should
    /// begin recognizing gestures. It delegates to the `gestureRecognizerShouldBeginBlock`
    /// if it exists, otherwise returns `false`.
    ///
    /// - Parameter gestureRecognizer: The gesture recognizer asking about beginning.
    /// - Returns: `true` if the gesture should begin, `false` otherwise.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizerShouldBeginBlock?(gestureRecognizer) ?? false
    }

    /// Handles tap gesture events.
    ///
    /// This method is called when the tap gesture recognizer detects a tap.
    /// It executes the `tapHandler` closure if it exists.
    ///
    /// - Parameter tap: The tap gesture recognizer that detected the tap.
    @objc
    private func handleTap(_ tap: UITapGestureRecognizer) {
        tapHandler?()
    }
}
