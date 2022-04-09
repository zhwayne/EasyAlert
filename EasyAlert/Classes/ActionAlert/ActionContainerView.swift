//
//  ActionContainerView.swift
//  EasyAlert
//
//  Created by iya on 2021/12/17.
//

import UIKit

class ActionContainerView: UIView {
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        
//        if #available(iOS 13.0, *) {
//            backgroundColor = UIColor.systemBackground
//        } else {
//            // Fallback on earlier versions
//            backgroundColor = .white
//        }
        
//        addSubview(stackView)
//        stackView.snp.makeConstraints { make in
//            make.edges.equalTo(UIEdgeInsets.zero)
////            make.left.right.bottom.equalToSuperview()
////            make.top.equalToSuperview().offset(1 / UIScreen.main.scale)
//        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 11.0, *) {
            layer.cornerRadius = ActionAlert.CornerRadius
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.bottomLeft, .bottomRight],
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
        
    func cleanSeparatorAndActionButtons() {
        for view in subviews where view != stackView {
            view.removeFromSuperview()
        }
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}
