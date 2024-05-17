//
//  KeyboardHandler.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

struct KeyboardContext {
    
    let keyboardFrame: CGRect
    let animationDuration: TimeInterval
    let curve: UIView.AnimationCurve
}

class KeyboardHandler: NSObject {

    typealias Handler = (KeyboardContext) -> Void
    
    var keyboardWillShow: Handler?
    
    var keyboardDidShow: Handler?

    var keyboardFrameWillChange: Handler?
    
    var keyboardWillHidden: Handler?
    
    var keyboardDidHidden: Handler?
        
    private var willShowToken: NotificationToken?
    private var didShowToken: NotificationToken?
    private var willHiddenToken: NotificationToken?
    private var didHiddenToken: NotificationToken?
    private var willChangeToken: NotificationToken?
    
    private(set) var keyboardFrame: CGRect?
    
    override init() {
        super.init()
        let center = NotificationCenter.default
        
        willShowToken = center.observe(name: UIApplication.keyboardWillShowNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let context = self?.context(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardFrame = context.keyboardFrame
                self?.keyboardWillShow?(context)
            }
        })
        
        didShowToken = center.observe(name: UIApplication.keyboardDidShowNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let context = self?.context(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardFrame = context.keyboardFrame
                self?.keyboardDidShow?(context)
            }
        })
        
        willHiddenToken = center.observe(name: UIApplication.keyboardWillHideNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let context = self?.context(from: userInfo, isHiddenKeyboard: true) {
                self?.keyboardFrame = context.keyboardFrame
                self?.keyboardWillHidden?(context)
            }
        })
        
        didHiddenToken = center.observe(name: UIApplication.keyboardDidHideNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let context = self?.context(from: userInfo, isHiddenKeyboard: true) {
                self?.keyboardFrame = context.keyboardFrame
                self?.keyboardDidHidden?(context)
            }
        })
        
        willChangeToken = center.observe(name: UIApplication.keyboardWillChangeFrameNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let context = self?.context(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardFrame = context.keyboardFrame
                self?.keyboardFrameWillChange?(context)
            }
        })
    }
}

extension KeyboardHandler {
    
    func context(from userInfo: [AnyHashable: Any], isHiddenKeyboard: Bool /* unused now */) -> KeyboardContext? {
        guard let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return nil
        }
        
        return KeyboardContext(
            keyboardFrame: frame,
            animationDuration: duration,
            curve: .easeInOut
        )
    }
}
