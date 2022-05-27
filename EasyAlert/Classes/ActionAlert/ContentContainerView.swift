//
//  ContentContainerView.swift
//  EasyAlert
//
//  Created by iya on 2022/1/14.
//

import UIKit

extension ActionAlert {
    
    final class ContentContainerView: UIView {
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            return stackView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            clipsToBounds = true
            
            if #available(iOS 13.0, *) {
                backgroundColor = UIColor.separator
                layer.cornerCurve = .continuous
            } else {
                // Fallback on earlier versions
                backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            }
            
            addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(1 / UIScreen.main.scale)
            }
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if #available(iOS 11.0, *) {
                layer.cornerRadius = ActionAlert.config.cornerRadius
                layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                let path = UIBezierPath(
                    roundedRect: bounds,
                    byRoundingCorners: [.bottomLeft, .bottomRight],
                    cornerRadii: CGSize(
                        width: ActionAlert.config.cornerRadius,
                        height: ActionAlert.config.cornerRadius
                    )
                )
                let mask = CAShapeLayer()
                mask.path = path.cgPath
                layer.mask = mask
            }
        }
        
        func cleanSubviews() {
            stackView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
}
