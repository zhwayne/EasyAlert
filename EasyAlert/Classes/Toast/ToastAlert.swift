//
//  ToastAlert.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

extension Message {
    
    var attributedText: NSAttributedString? {
        if let string = self as? String {
            return NSAttributedString(string: string)
        }
        if let string = self as? NSAttributedString {
            return string
        }
        if #available(iOS 15, *), let string = self as? AttributedString {
            return NSAttributedString(string)
        }
        return nil
    }
}

final class ToastAlert: Alert {
    
    class ContentView: UIView, AlertCustomizable {
        
        let label = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 3)
            layer.shadowOpacity = 0.2
            layer.shadowRadius = 4
            
            let blurEffect: UIBlurEffect
            if #available(iOS 13.0, *) {
                blurEffect = UIBlurEffect(style: .systemMaterialDark)
            } else {
                blurEffect = UIBlurEffect(style: .dark)
            }
            let effectView = UIVisualEffectView(effect: blurEffect)
            effectView.clipsToBounds = true
            effectView.frame = bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            effectView.layer.cornerRadius = 15
            if #available(iOS 13.0, *) {
                effectView.layer.cornerCurve = .continuous
            }
            addSubview(effectView)
            
            label.textColor = .white
            label.font = .systemFont(ofSize: 15)
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var rawCustomView: ContentView { customView as! ContentView }
    
    public required init(message: Message) {
        let contentView = ContentView()
        contentView.label.attributedText = message.attributedText
        super.init(customView: contentView)
        
        transitionCoordinator = ToastTransitionCoordinator()
        backdropProvider.dimming = .color(.clear)
        backdropProvider.penetrateScope = .all
    }
    
    @available(*, unavailable)
    override init(customView: Alert.CustomizedView) {
        fatalError("Use `init(message:)` instead.")
    }
}
