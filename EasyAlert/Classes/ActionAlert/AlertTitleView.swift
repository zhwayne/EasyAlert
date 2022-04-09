//
//  AlertTitleView.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/11/19.
//

import UIKit
import SnapKit

final class AlertTitleView: UIView {
    
    private let titleEdgeInsets = UIEdgeInsets(top: 20, left: 16, bottom: 12, right: 16)
    
    let titleLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            // Fallback on earlier versions
            label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.edges.equalTo(titleEdgeInsets)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 11.0, *) {
            layer.cornerRadius = ActionAlert.CornerRadius
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(
                    width: ActionAlert.CornerRadius,
                    height: ActionAlert.CornerRadius
                )
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}
