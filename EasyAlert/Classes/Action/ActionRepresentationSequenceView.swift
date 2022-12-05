//
//  ActionRepresentationSequenceView.swift
//  EasyAlert
//
//  Created by iya on 2021/12/17.
//

import UIKit

final class ActionRepresentationSequenceView: UIView {
    
    let contentView = ActionSeparatableSequenceView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
