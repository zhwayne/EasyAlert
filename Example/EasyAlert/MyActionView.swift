//
//  MyActionView.swift
//  EasyAlert_Example
//
//  Created by iya on 2022/5/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EasyAlert

final class MyActionView: Action.CustomizedView {
    
    var isHighlighted: Bool = false {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    let style: Action.Style
    
    var isEnabled: Bool = true
        
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = style.color
        label.clipsToBounds = true
        return label
    }()
    
    required init(style: Action.Style) {
        self.style = style
        super.init(frame: .zero)
        
        clipsToBounds = true
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("using init(style:) instead.")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = 40
        return size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.layer.cornerRadius = 10
    }
}

fileprivate extension Action.Style {
    
    var color: UIColor {
        switch self {
        case .`default`: return .systemOrange
        case .cancel: return .lightGray.withAlphaComponent(0.5)
        case .destructive: return .systemRed
        }
    }
}
