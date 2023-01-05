//
//  ActionRepresentationSequenceView.swift
//  EasyAlert
//
//  Created by iya on 2021/12/17.
//

import UIKit

final class ActionRepresentationSequenceView: UIView {
    
    let separatableSequenceView = ActionSeparatableSequenceView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        separatableSequenceView.frame = bounds
        separatableSequenceView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(separatableSequenceView)
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
