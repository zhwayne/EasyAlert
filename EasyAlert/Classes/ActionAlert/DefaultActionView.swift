//
//  DefaultActionView.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

final class DefaultActionView: Action.CustomizedView {
        
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    let style: Action.Style
    
    var isEnabled: Bool = true
    
    var isHighlighted: Bool = false
        
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = style.color
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
        size.height = 44
        return size
    }
}

fileprivate extension Action.Style {
    
    var color: UIColor {
        switch self {
        case .`default`: return .systemBlue
        case .cancel: return .systemGray
        case .destructive: return .systemRed
        }
    }
}
