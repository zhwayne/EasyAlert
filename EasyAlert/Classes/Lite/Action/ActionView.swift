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
    
    let alertbleStyle: AlertbleStyle
    
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
        label.font = style.font(for: alertbleStyle)
        label.textAlignment = .center
        label.textColor = style.color
        return label
    }()
    
    required init(style: Action.Style, alertbleStyle: AlertbleStyle) {
        self.style = style
        self.alertbleStyle = alertbleStyle
        super.init(frame: .zero)
        
        clipsToBounds = true
        addSubview(highlightedOverlay)
        addSubview(titleLabel)
        
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
    
    convenience init(style: Action.Style) {
        self.init(style: style, alertbleStyle: .alert)
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
        switch alertbleStyle {
        case .alert: size.height = 44
        case .sheet: size.height = 57
        }
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
    
    func font(for alertbleStyle: AlertbleStyle) -> UIFont {
        let fontSize: CGFloat
        switch alertbleStyle {
        case .alert: fontSize = 17
        case .sheet: fontSize = 20
        }
        switch self {
        case .`default`: return .systemFont(ofSize: fontSize, weight: .regular)
        case .cancel: return .systemFont(ofSize: fontSize, weight: .semibold)
        case .destructive: return .systemFont(ofSize: fontSize, weight: .regular)
        }
    }
}
