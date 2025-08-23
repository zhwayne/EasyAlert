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
        
        backgroundColor = .secondarySystemGroupedBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
