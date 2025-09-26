//
//  ActionSeparatableSequenceView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/2.
//

import UIKit

final class ActionSeparatableSequenceView: UIView {

    private var horizontalSeparators: [ActionVibrantSeparatorView] = []
    private var verticalSeparators: [ActionVibrantSeparatorView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerCurve = .continuous
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCornerRadius(_ radius: CGFloat, corners: UIRectCorner = .allCorners) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners.layerMaskedCorners
        layer.cornerCurve = .continuous
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

extension UIRectCorner {

    var layerMaskedCorners: CACornerMask {
        var mask = CACornerMask(rawValue: 0)
        if contains(.topLeft) { mask.insert(.layerMinXMinYCorner) }
        if contains(.topRight) { mask.insert(.layerMaxXMinYCorner) }
        if contains(.bottomLeft) { mask.insert(.layerMinXMaxYCorner) }
        if contains(.bottomRight) { mask.insert(.layerMaxXMaxYCorner) }
        return mask
    }
}
