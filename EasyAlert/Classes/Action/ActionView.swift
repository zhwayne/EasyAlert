//
//  DefaultActionView.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

final class ActionView: Action.CustomizedView {
    
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
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = style.font
        label.textAlignment = .center
        label.textColor = style.color
        return label
    }()
    
    required init(style: Action.Style) {
        self.style = style
        super.init(frame: .zero)
        
        clipsToBounds = true
        addSubview(highlightedOverlay)
        addSubview(titleLabel)
        highlightedOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
        size.height = 45
        return size
    }
}

fileprivate extension Action.Style {
    
    var color: UIColor {
        switch self {
        case .`default`: return .systemBlue
        case .cancel: return .systemBlue
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
