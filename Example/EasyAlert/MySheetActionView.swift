//
//  MySheetActionView.swift
//  EasyAlert_Example
//
//  Created by xxx on 2024/1/11.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import EasyAlert

final class MySheetActionView: UIView, ActionCustomizable {
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var isHighlighted: Bool = false {
        didSet {
            highlightedOverlay.alpha = isHighlighted ? 1 : 0
        }
    }
    
    let style: Action.Style
    
    var isEnabled: Bool = true {
        didSet {
            highlightedOverlay.alpha = isEnabled ? 0 : 1
        }
    }
    
    private let highlightedOverlay: UIView = {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemFill
        } else {
            view.backgroundColor = UIColor(white: 0.472, alpha: 0.36)
        }
        view.alpha = 0
        view.isUserInteractionEnabled = false
        view.autoresizingMask = []
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = font(for: style)
        label.textAlignment = .center
        label.textColor = color(for: style)
        label.backgroundColor = backgroundColor(for: style)
        label.autoresizingMask = []
        return label
    }()
    
    required init(style: Action.Style) {
        self.style = style
        super.init(frame: .zero)
        
        clipsToBounds = true
        addSubview(titleLabel)
        addSubview(highlightedOverlay)
        
        highlightedOverlay.translatesAutoresizingMaskIntoConstraints = false
        highlightedOverlay.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        highlightedOverlay.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        highlightedOverlay.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        highlightedOverlay.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
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
        size.height = 54
        return size
    }
}

fileprivate extension MySheetActionView {
    
    func color(for style: Action.Style) -> UIColor {
        .white
    }
    
    func backgroundColor(for style: Action.Style) -> UIColor {
        if case .cancel = style {
            return UIColor(red: 0.44, green: 0.30, blue: 0.63, alpha: 1.00)
        }
        return UIColor(red: 0.29, green: 0.27, blue: 0.40, alpha: 1.00)
    }
    
    func font(for style: Action.Style) -> UIFont {
        .systemFont(ofSize: 16, weight: .medium)
    }
}
