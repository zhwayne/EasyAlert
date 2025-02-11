//
//  AlertTapTarget.swift
//  EasyAlert
//
//  Created by iya on 2021/7/28.
//

import UIKit

final class TapTarget: NSObject, UIGestureRecognizerDelegate {
    
    var gestureRecognizerShouldBeginBlock: ((UIGestureRecognizer) -> Bool)?
    
    var tapHandler: (() -> Void)?
    
    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        return tap
    }()
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizerShouldBeginBlock?(gestureRecognizer) ?? false
    }
    
    @objc
    private func handleTap(_ tap: UITapGestureRecognizer) {
        tapHandler?()
    }
}
