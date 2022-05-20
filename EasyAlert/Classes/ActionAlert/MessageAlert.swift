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
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateEdges(_ edges: UIEdgeInsets) {
            label.snp.remakeConstraints { maker in
                maker.edges.equalTo(edges)
            }
        }
    }
    
    private let messageView: MessageView
    
    @available(*, unavailable)
    public required init(title: Title?, customView: ActionAlert.CustomizedView) {
        fatalError()
    }
        
    public required init(title: Title?, message: Message?) {
        messageView = MessageView()
        messageView.label.attributedText = message?.message
        messageView.isHidden = message == nil
        super.init(title: title, customView: messageView)
    }
    
    public override func willLayoutContainer() {
        super.willLayoutContainer()
        if title == nil {
            messageView.updateEdges(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        } else {
            messageView.updateEdges(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))
        }
    }
}
