//
//  DimmingView.swift
//  EasyAlert
//
//  Created by iya on 2022/5/28.
//

import Foundation

extension Alert {
    
    class DimmingView : UIView {
        
        var contentView: UIView? {
            didSet {
                guard oldValue != contentView else { return }
                oldValue?.removeFromSuperview()
                guard let contentView = contentView else { return }
                addSubview(contentView)
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            contentView?.frame = bounds
        }
    }
}
