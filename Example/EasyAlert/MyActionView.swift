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
            alpha = isHighlighted ? 0.3 : 1
        }
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    let style: Action.Style
    
    var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1 : 0.3
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = style.font
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = style.color
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        if #available(iOS 13.0, *) {
            label.layer.cornerCurve = .continuous
        }
        return label
    }()
    
    required init(style: Action.Style) {
        self.style = style
        super.init(frame: .zero)
        
        clipsToBounds = true
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
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
    
    var font: UIFont {
        switch self {
        case .`default`: return .systemFont(ofSize: 17, weight: .regular)
        case .cancel: return .systemFont(ofSize: 17, weight: .semibold)
        case .destructive: return .systemFont(ofSize: 17, weight: .regular)
        }
    }
}
