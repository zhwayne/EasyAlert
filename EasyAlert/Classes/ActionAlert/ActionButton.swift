//
//  ActionButton.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/8/2.
//

import UIKit

internal class ActionButton: UIButton {
    
    weak var action: Action?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = 44
        return size
    }
}
