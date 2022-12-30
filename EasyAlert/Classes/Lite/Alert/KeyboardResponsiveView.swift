//
//  KeyboardResponsiveView.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import UIKit

struct KeyboardAdaptation {
    
    let keyboardFrame: CGRect
    let animationDuration: TimeInterval
    let curve: UIView.AnimationCurve
}

class KeyboardResponsiveView: UIView {

    typealias Handler = (KeyboardAdaptation) -> Void
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let center = NotificationCenter.default
        
        willShowToken = center.observe(name: UIApplication.keyboardWillShowNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let adaptation = self?.adaptation(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardFrame = adaptation.keyboardFrame
                self?.keyboardWillShow?(adaptation)
            }
        })
        
        didShowToken = center.observe(name: UIApplication.keyboardDidShowNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let adaptation = self?.adaptation(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardFrame = adaptation.keyboardFrame
                self?.keyboardDidShow?(adaptation)
            }
        })
        
        willHiddenToken = center.observe(name: UIApplication.keyboardWillHideNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let adaptation = self?.adaptation(from: userInfo, isHiddenKeyboard: true) {
                self?.keyboardFrame = adaptation.keyboardFrame
                self?.keyboardWillHidden?(adaptation)
            }
        })
        
        didHiddenToken = center.observe(name: UIApplication.keyboardDidHideNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let adaptation = self?.adaptation(from: userInfo, isHiddenKeyboard: true) {
                self?.keyboardFrame = adaptation.keyboardFrame
                self?.keyboardDidHidden?(adaptation)
            }
        })
        
        willChangeToken = center.observe(name: UIApplication.keyboardWillChangeFrameNotification, using: { [weak self] note in
            if let userInfo = note.userInfo,
               let adaptation = self?.adaptation(from: userInfo, isHiddenKeyboard: false) {
                self?.keyboardFrame = adaptation.keyboardFrame
                self?.keyboardFrameWillChange?(adaptation)
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KeyboardResponsiveView {
    
    func adaptation(from userInfo: [AnyHashable: Any], isHiddenKeyboard: Bool /* unused now */) -> KeyboardAdaptation? {
        guard let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return nil
        }
        
        let adaptation = KeyboardAdaptation(
            keyboardFrame: frame,
            animationDuration: duration,
            curve: .easeInOut
        )
        return adaptation
    }
}
