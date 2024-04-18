//
//  ActionSheetActionView.swift
//  EasyAlert
//
//  Created by iya on 2023/1/5.
//

import UIKit

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
            label.backgroundColor = backgroundColor(for: style)
            return label
        }()
        
        required init(style: Action.Style) {
            self.style = style
            super.init(frame: .zero)
            
            clipsToBounds = true
            addSubview(titleLabel)
            addSubview(highlightedOverlay)
            
            highlightedOverlay.frame = bounds
            highlightedOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            titleLabel.frame = bounds
            titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
    
    func backgroundColor(for style: Action.Style) -> UIColor {
        if case .cancel = style {
            if #available(iOS 13.0, *) {
                return .systemBackground
            } else {
                // Fallback on earlier versions
                return .white
            }
        }
        return .clear
    }
    
    func font(for style: Action.Style) -> UIFont {
        switch style {
        case .`default`: return .systemFont(ofSize: 20, weight: .regular)
        case .cancel: return .systemFont(ofSize: 20, weight: .semibold)
        case .destructive: return .systemFont(ofSize: 20, weight: .regular)
        }
    }
}
