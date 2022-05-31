//
//  ActionRepresentationSequenceView.swift
//  EasyAlert
//
//  Created by iya on 2021/12/17.
//

import UIKit

final class ActionRepresentationSequenceView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        if #available(iOS 11.0, *) {
            layer.cornerRadius = radius
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(
                    width: radius,
                    height: radius
                )
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}
