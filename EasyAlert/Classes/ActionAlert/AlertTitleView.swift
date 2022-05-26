//
//  AlertTitleView.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/11/19.
//

import UIKit
import SnapKit

final class AlertTitleView: UIView {
    
    private let titleEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 8, right: 20)
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = ActionAlert.configuration.titleAlignment
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
            layer.cornerRadius = ActionAlert.configuration.cornerRadius
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.topLeft, .topRight],
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
