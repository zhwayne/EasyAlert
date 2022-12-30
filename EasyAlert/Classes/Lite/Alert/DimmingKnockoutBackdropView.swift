//
//  DimmingKnockoutBackdropView.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

final class DimmingKnockoutBackdropView: UIView {
    
    var willRemoveFromSuperviewObserver: (() -> Void)?
    
    var hitTest: ((UIView, CGPoint) -> Bool)?

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview == nil {
            willRemoveFromSuperviewObserver?()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let returnsNil = hitTest?(self, point), returnsNil == true {
            return nil
        }
        return super.hitTest(point, with: event)
    }
}
