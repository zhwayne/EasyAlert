//
//  KeyboardResponsive.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

/// Information about keyboard events including frame, animation details, and visibility state.
///
/// `KeyboardInfo` encapsulates all the relevant information about a keyboard event,
/// including the keyboard's frame, animation duration, curve, and whether it's hidden.
@MainActor
public struct KeyboardInfo {

    /// The frame of the keyboard in the screen coordinate system.
    public let keyboardFrame: CGRect
    
    /// The duration of the keyboard animation in seconds.
    public let animationDuration: TimeInterval
    
    /// The animation curve used for the keyboard animation.
    public let curve: UIView.AnimationCurve
    
    /// A Boolean value indicating whether the keyboard is hidden.
    public var isHidden: Bool
}

/// A monitor that tracks keyboard events and provides callbacks for different keyboard states.
///
/// `KeyboardEventMonitor` observes keyboard notifications and provides a convenient
/// way to respond to keyboard show, hide, and frame change events. It automatically
/// parses keyboard information from notification user info and provides type-safe callbacks.
@MainActor
final class KeyboardEventMonitor {

    /// A closure type for handling keyboard events.
    typealias KeyboardEventHandler = (KeyboardInfo) -> Void

    /// A closure called when the keyboard is about to show.
    var keyboardWillShow: KeyboardEventHandler?

    /// A closure called when the keyboard has finished showing.
    var keyboardDidShow: KeyboardEventHandler?

    /// A closure called when the keyboard frame is about to change.
    var keyboardFrameWillChange: KeyboardEventHandler?

    /// A closure called when the keyboard is about to hide.
    var keyboardWillHide: KeyboardEventHandler?

    /// A closure called when the keyboard has finished hiding.
    var keyboardDidHide: KeyboardEventHandler?

    /// Notification tokens for keyboard event observations.
    private var willShowToken: NotificationToken?
    private var didShowToken: NotificationToken?
    private var willHideToken: NotificationToken?
    private var didHideToken: NotificationToken?
    private var willChangeToken: NotificationToken?

    /// The current keyboard information, updated with each keyboard event.
    private(set) var keyboardInfo: KeyboardInfo?

    /// Creates a new keyboard event monitor and begins observing keyboard notifications.
    ///
    /// This initializer automatically sets up observers for all keyboard events
    /// and begins monitoring for keyboard state changes.
    init() {

        let center = NotificationCenter.default

        // Observe keyboard will show notification
        willShowToken = center.observe(name: UIApplication.keyboardWillShowNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let info = self?.keyboardInfo(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardInfo = info
                self?.keyboardWillShow?(info)
            }
        })

        // Observe keyboard did show notification
        didShowToken = center.observe(name: UIApplication.keyboardDidShowNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let info = self?.keyboardInfo(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardInfo = info
                self?.keyboardDidShow?(info)
            }
        })

        // Observe keyboard will hide notification
        willHideToken = center.observe(name: UIApplication.keyboardWillHideNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let info = self?.keyboardInfo(from: userInfo, isHiddenKeyboard: true) {
                self?.keyboardInfo = info
                self?.keyboardWillHide?(info)
            }
        })

        // Observe keyboard did hide notification
        didHideToken = center.observe(name: UIApplication.keyboardDidHideNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let info = self?.keyboardInfo(from: userInfo, isHiddenKeyboard: true) {
                self?.keyboardInfo = info
                self?.keyboardDidHide?(info)
            }
        })

        // Observe keyboard frame change notification
        willChangeToken = center.observe(name: UIApplication.keyboardWillChangeFrameNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let info = self?.keyboardInfo(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardInfo = info
                self?.keyboardFrameWillChange?(info)
            }
        })
    }

    /// This initializer is not supported.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KeyboardEventMonitor {

    /// Creates keyboard information from notification user info.
    ///
    /// This method extracts keyboard information from the user info dictionary
    /// of a keyboard notification, including frame, animation duration, and visibility state.
    ///
    /// - Parameters:
    ///   - userInfo: The user info dictionary from the keyboard notification.
    ///   - isHiddenKeyboard: A Boolean indicating whether the keyboard is hidden.
    /// - Returns: A `KeyboardInfo` object containing the extracted information, or `nil` if the required data is missing.
    private func keyboardInfo(
        from userInfo: [AnyHashable: Any],
        isHiddenKeyboard: Bool /* unused now */
    ) -> KeyboardInfo? {
        guard let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return nil
        }

        let info = KeyboardInfo(
            keyboardFrame: frame,
            animationDuration: duration,
            curve: .easeInOut,
            isHidden: isHiddenKeyboard
        )
        return info
    }
}
