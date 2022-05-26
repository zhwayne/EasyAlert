//
//  ActionContainerView.swift
//  EasyAlert
//
//  Created by iya on 2021/12/17.
//

import UIKit

final class ActionContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 11.0, *) {
            layer.cornerRadius = ActionAlert.configuration.cornerRadius
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(
                    width: ActionAlert.configuration.cornerRadius,
                    height: ActionAlert.configuration.cornerRadius
                )
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}
