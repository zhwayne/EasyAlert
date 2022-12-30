//
//  ActionVibrantSeparatorView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/5.
//

import UIKit

class ActionVibrantSeparatorView: UIView {
    
    required init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let blureEffect: UIBlurEffect
        let vibrancyEffect: UIVisualEffect
        if #available(iOS 13.0, *) {
            blureEffect = UIBlurEffect(style: .systemMaterial)
            vibrancyEffect = UIVibrancyEffect(blurEffect: blureEffect, style: .separator)
        } else {
            blureEffect = UIBlurEffect(style: .dark)
            vibrancyEffect = UIVibrancyEffect(blurEffect: blureEffect)
        }
        let effectView = UIVisualEffectView(effect: vibrancyEffect)
        effectView.contentView.backgroundColor = .white
        addSubview(effectView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.first?.frame = bounds
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
