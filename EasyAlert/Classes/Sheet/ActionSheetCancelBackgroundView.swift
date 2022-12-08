//
//  ActionSheetCancelBackgroundView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/8.
//

import UIKit

class ActionSheetCancelBackgroundView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13.0, *) {
            backgroundColor = .secondarySystemGroupedBackground
        } else {
            // Fallback on earlier versions
            backgroundColor = .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
