//
//  ActionSheetActionView.swift
//  EasyAlert
//
//  Created by iya on 2023/1/5.
//

import Foundation

extension ActionSheet {
    
    final class ActionView: UIView, ActionCustomizable {
        
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
            label.font = font(for: style)
            label.textAlignment = .center
            label.textColor = color(for: style)
            return label
        }()
        
        required init(style: Action.Style) {
            self.style = style
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
            size.height = 57
            return size
        }
    }
}

fileprivate extension ActionSheet.ActionView {
    
    func color(for style: Action.Style) -> UIColor {
        switch style {
        case .`default`: return .systemBlue
        case .cancel: return .systemBlue
        case .destructive: return .systemRed
        }
    }
    
    func font(for style: Action.Style) -> UIFont {
        switch style {
        case .`default`: return .systemFont(ofSize: 20, weight: .regular)
        case .cancel: return .systemFont(ofSize: 20, weight: .semibold)
        case .destructive: return .systemFont(ofSize: 20, weight: .regular)
        }
    }
}
