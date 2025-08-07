//
//  ToastAlert.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

final class ToastAlert: Alert {
    
    class ContentView: UIView, AlertContent {
        
        let label = UILabel()
        let indicator = UIActivityIndicatorView(style: .white)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowOpacity = 0.1
            layer.shadowRadius = 5

            let effectView = BlurEffectView(frame: .zero)
            effectView.blurRadius = 50
            if #available(iOS 13.0, *) {
                effectView.colorTint = UIColor.init(dynamicProvider: { tc in
                    if tc.userInterfaceStyle == .dark {
                        return .systemGray
                    } else {
                        return .black
                    }
                })
            } else {
                // Fallback on earlier versions
                effectView.colorTint = UIColor.black
            }
            effectView.colorTintAlpha = 0.4
            effectView.clipsToBounds = true
            effectView.frame = bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            effectView.layer.cornerRadius = 13
            effectView.contentView.backgroundColor = UIColor(white: 0, alpha: 0.2)
            if #available(iOS 13.0, *) {
                effectView.layer.cornerCurve = .continuous
            }
            addSubview(effectView)
            
            label.numberOfLines = 0
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            indicator.isHidden = true
            indicator.setContentHuggingPriority(.required, for: .horizontal)
            
            let stackView = UIStackView(arrangedSubviews: [indicator, label])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.spacing = 8
            stackView.alignment = .center
            addSubview(stackView)
            
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var rawCustomView: ContentView { alertContent as! ContentView }
    
    public required init(message: Message) {
        let contentView = ContentView()
        super.init(content: contentView)
        contentView.label.attributedText = Toast.text(for: message)
        
        aniamtor = ToastTransitionAnimator()
        layout = ToastLayout()
        backdrop.dimming = .color(.clear)
        backdrop.interactionScope = .all
        
        layoutGuide = AlertLayoutGuide(
            width: .flexible,
            height: .flexible,
            contentInsets: UIEdgeInsets(top: 0, left: 36, bottom: 0, right: 36)
        )
    }
    
    override func willShow() {
        super.willShow()
        if let window = rawCustomView.window {
            window.windowLevel = UIWindow.Level(.greatestFiniteMagnitude)
        }
        if !rawCustomView.indicator.isHidden {
            rawCustomView.indicator.startAnimating()
        }
    }
    
    override func didDismiss() {
        super.didDismiss()
        rawCustomView.indicator.stopAnimating()
    }
}

extension Toast {
    
    static func text(for message: Message?) -> NSAttributedString? {
        if let text = message as? String {
            return attributedMessage(text)
        }
        if #available(iOS 15, *), let text = message as? AttributedString {
            return NSAttributedString(text)
        }
        return message as? NSAttributedString
    }
}

extension Toast {
    
    static private var messageAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byCharWrapping
        attributes[.font] = UIFont.systemFont(ofSize: 15)
        attributes[.foregroundColor] = UIColor.white
        attributes[.paragraphStyle] = paragraphStyle.copy()
        return attributes
    }
    
    static func attributedMessage(_ message: String) -> NSAttributedString {
        let range = NSMakeRange(0, message.count)
        let attributedMessage = NSMutableAttributedString(string: message)
        attributedMessage.addAttributes(messageAttributes, range: range)
        return NSAttributedString(attributedString: attributedMessage)
    }
}
