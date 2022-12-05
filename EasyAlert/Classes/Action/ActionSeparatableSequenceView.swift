//
//  ActionSeparatableSequenceView.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/2.
//

import UIKit

final class ActionSeparatableSequenceView: UIView {
    
    private var horizontalSeparators: [ActionVibrantSeparatorView] = []
    private var verticalSeparators: [ActionVibrantSeparatorView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        isUserInteractionEnabled = false
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
    
    func horizontalSeparator(at index: Int) -> UIView {
        guard index < horizontalSeparators.count else {
            horizontalSeparators.append(ActionVibrantSeparatorView())
            return horizontalSeparator(at: index)
        }
        return horizontalSeparators[index]
    }
    
    func verticalSeparator(at index: Int) -> UIView {
        guard index < verticalSeparators.count else {
            verticalSeparators.append(ActionVibrantSeparatorView())
            return verticalSeparator(at: index)
        }
        return verticalSeparators[index]
    }
}