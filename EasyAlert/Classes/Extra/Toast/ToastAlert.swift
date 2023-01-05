//
//  ToastAlert.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

final class ToastAlert: Alert {
    
    class ContentView: UIView, AlertCustomizable {
        
        let label = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowOpacity = 0.1
            layer.shadowRadius = 5
            
            let blurEffect: UIBlurEffect
            if #available(iOS 13.0, *) {
                blurEffect = UIBlurEffect(style: .systemMaterialDark)
            } else {
                blurEffect = UIBlurEffect(style: .dark)
            }
            let effectView = BlurEffectView(effect: blurEffect, intensity: 0.75)
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
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var rawCustomView: ContentView { customizable as! ContentView }
    
    public required init(message: Message) {
        let contentView = ContentView()
        super.init(customizable: contentView)
        contentView.label.attributedText = Toast.text(for: message)
        
        transitionAniamtor = ToastTransitionAnimator()
        backdropProvider.dimming = .color(.clear)
        backdropProvider.penetrationScope = .all
        
        let bounds = UIScreen.main.bounds
        let width = min(bounds.width, bounds.height)
        layoutGuide = LayoutGuide(width: .flexible(width),
                                  edgeInsets: UIEdgeInsets(top: 0, left: -50, bottom: 0, right: -50))
    }
    
    override func willShow() {
        super.willShow()
        if let window = rawCustomView.window {
            window.windowLevel = UIWindow.Level(.greatestFiniteMagnitude)
        }
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
