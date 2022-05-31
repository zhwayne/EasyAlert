//
//  BackgroundView.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/27.
//

import UIKit

final class BackgroundView: UIView {

    weak var alert: Alertble?
    
    var willRemoveFromSuperviewObserver: (() -> Void)?

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview == nil {
            willRemoveFromSuperviewObserver?()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
