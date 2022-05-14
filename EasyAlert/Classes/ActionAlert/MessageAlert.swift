//
//  MessageAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/8/2.
//

import UIKit
import SnapKit

public final class MessageAlert: ActionAlert {
    
    public var title: String? {
        alertCustomView.titleView.titleLabel.text
    }
    
    private final class MessageView: UIView, AlertCustomizable {
        
        fileprivate let label = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
//            if #available(iOS 13.0, *) {
//                backgroundColor = .systemBackground
//            } else {
//                backgroundColor = .white
//            }
            label.numberOfLines = 0
            addSubview(label)
            
            label.snp.makeConstraints { maker in
                maker.edges.equalTo(UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16))
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    @available(*, unavailable)
    public required init(title: Title?, customView: ActionAlert.CustomizedView) {
        fatalError()
    }
    
    public required init(title: Title?, message: Message?) {
        let messageView = MessageView()
        messageView.label.attributedText = message?.message
        messageView.isHidden = message == nil
        super.init(title: title, customView: messageView)
    }
}
