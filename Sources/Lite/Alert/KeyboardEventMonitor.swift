//
//  KeyboardResponsive.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

@MainActor
public struct KeyboardInfo {

    public let keyboardFrame: CGRect
    public let animationDuration: TimeInterval
    public let curve: UIView.AnimationCurve
    public var isHidden: Bool
}

@MainActor
final class KeyboardEventMonitor {

    typealias KeyboardEventHandler = (KeyboardInfo) -> Void

    var keyboardWillShow: KeyboardEventHandler?

    var keyboardDidShow: KeyboardEventHandler?

    var keyboardFrameWillChange: KeyboardEventHandler?

    var keyboardWillHide: KeyboardEventHandler?

    var keyboardDidHide: KeyboardEventHandler?

    private var willShowToken: NotificationToken?
    private var didShowToken: NotificationToken?
    private var willHideToken: NotificationToken?
    private var didHideToken: NotificationToken?
    private var willChangeToken: NotificationToken?

    private(set) var keyboardInfo: KeyboardInfo?

    init() {

        let center = NotificationCenter.default

        willShowToken = center.observe(name: UIApplication.keyboardWillShowNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let info = self?.keyboardInfo(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardInfo = info
                self?.keyboardWillShow?(info)
            }
        })

        didShowToken = center.observe(name: UIApplication.keyboardDidShowNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let info = self?.keyboardInfo(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardInfo = info
                self?.keyboardDidShow?(info)
            }
        })

        willHideToken = center.observe(name: UIApplication.keyboardWillHideNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let info = self?.keyboardInfo(from: userInfo, isHiddenKeyboard: true) {
                self?.keyboardInfo = info
                self?.keyboardWillHide?(info)
            }
        })

        didHideToken = center.observe(name: UIApplication.keyboardDidHideNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let info = self?.keyboardInfo(from: userInfo, isHiddenKeyboard: true) {
                self?.keyboardInfo = info
                self?.keyboardDidHide?(info)
            }
        })

        willChangeToken = center.observe(name: UIApplication.keyboardWillChangeFrameNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let info = self?.keyboardInfo(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardInfo = info
                self?.keyboardFrameWillChange?(info)
            }
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KeyboardEventMonitor {

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
