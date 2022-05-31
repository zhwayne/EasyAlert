//
//  ActionRepresentationView.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/8/2.
//

import UIKit

final class ActionRepresentationView: UIControl {
    
    var action: Action? {
        didSet {
            oldValue?.view.removeFromSuperview()
            if let view = action?.view {
                addSubview(view)
            }
        }
    }
    
    override var isHighlighted: Bool {
        willSet {
            action?.view.isHighlighted = newValue
        }
    }
    
    override var isEnabled: Bool {
        willSet {
            action?.view.isEnabled = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return action?.view.intrinsicContentSize ?? .zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        action?.view.frame = bounds
        action?.view.isUserInteractionEnabled = false
    }
}
