//
//  AlertTapTarget.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/28.
//

import UIKit

extension Alert {
    
    class TapTarget: NSObject, UIGestureRecognizerDelegate {
        
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
}
