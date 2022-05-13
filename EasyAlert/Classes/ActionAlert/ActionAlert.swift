//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/28.
//

import UIKit
import SnapKit

open class ActionAlert: Alert {
    
    static let CornerRadius: CGFloat = 13
    
    let alertCustomView: ActionAlertCustomView
    
    public required init(title: Title?, customView: CustomizedView) {
        alertCustomView = ActionAlertCustomView(customView: customView)
        alertCustomView.titleView.titleLabel.attributedText = title?.title
        super.init(customView: alertCustomView)
        let layout = ActionAlertLayout()
        layout.alertCustomView = alertCustomView
        self.layout = layout
    }
}

extension ActionAlert: ActionAlertble {
    
    public func add(action: Action) {
        assert(isShowing == false)
        alertCustomView.actions.append(action)
        action.alert = self
    }
    
    public func add(actions: [Action]) {
        assert(isShowing == false)
        alertCustomView.actions.append(contentsOf: actions)
        actions.forEach { $0.alert = self }
    }
}

extension ActionAlert {
    func setAction(_ action: Action, enabled: Bool) {
        fatalError("暂未实现此功能")
    }
}

extension ActionAlert {
    
    final class ActionAlertCustomView: UIView, AlertCustomable {
        
        var actions: [Action] = []
        
        let customView: UIView
        
        lazy var titleView = AlertTitleView()
        
        lazy var actionContainerView = ActionContainerView()
                
        private(set) lazy var contentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            return stackView
        }()
        
        required init(customView: UIView) {
            self.customView = customView
            super.init(frame: .zero)
        }
        
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            guard superview != nil else { return }
            
            if let _ = titleView.titleLabel.text {
                contentStackView.addArrangedSubview(titleView)
            }
            contentStackView.addArrangedSubview(customView)
            if !actions.isEmpty {
                contentStackView.addArrangedSubview(actionContainerView)
            }
            addSubview(contentStackView)
            contentStackView.snp.remakeConstraints { maker in
                maker.edges.equalToSuperview()
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateLayout(interfaceOrientation: UIInterfaceOrientation, width: Alert.Width) {
            guard !actions.isEmpty else { return }
            for view in actionContainerView.subviews {
                view.removeFromSuperview()
            }
            
            let globalAttributes = Action.Style.globalAttributes
            
            let backgroundColor = globalAttributes[.backgroundColor] as! UIColor
            let itemSpacing = globalAttributes[.itemSpacing] as! CGFloat
            // let separatorColor = globalAttributes[.separatorColor] as! UIColor
            
            actionContainerView.backgroundColor = backgroundColor

            var actionIdx = 0
            var lastButton: ActionButton!
            let actionCount = actions.count
            actions.forEach { action in
                let attributes = action.style.attributes
                
                var stringAttr = [NSAttributedString.Key: Any]()
                stringAttr[.font] = attributes[.font]
                stringAttr[.foregroundColor] = attributes[.textColor]
                
                let title = NSAttributedString(string: action.title ?? "", attributes: stringAttr)
                let button = ActionButton(type: .system)
                button.setAttributedTitle(title, for: .normal)
                button.backgroundColor = (attributes[.itemBackgroundColor] as! UIColor)
                
                button.addTarget(self, action: #selector(handleActionButtonTouchUpInside(_:)), for: .touchUpInside)
                button.action = action
    
                actionContainerView.addSubview(button)
                let height = attributes[.itemHeight] as! CGFloat
                let edgeInsets = attributes[.itemEdgeInsets] as! UIEdgeInsets
                var cornerRadius = attributes[.itemCornerRadius] as! CGFloat
                
                cornerRadius = cornerRadius == Action.roundCornerRadius ? height / 2 : cornerRadius
                button.layer.cornerRadius = cornerRadius
                
                if actionCount == 1 {
                    button.snp.makeConstraints {
                        $0.height.equalTo(height)
                        $0.edges.equalTo(edgeInsets)
                    }
                } else if actionCount == 2 {
                    button.snp.makeConstraints {
                        $0.height.equalTo(height)
                        $0.top.equalTo(edgeInsets.top)
                        $0.bottom.equalTo(-edgeInsets.bottom)
                        if actionIdx == 0 {
                            $0.left.equalTo(edgeInsets.left + -(itemSpacing) * 0.5)
                        } else {
                            $0.right.equalTo(-edgeInsets.right + itemSpacing * 0.5)
                            $0.left.equalTo(lastButton.snp.right).offset(edgeInsets.left + edgeInsets.right + itemSpacing)
                            $0.width.equalTo(lastButton)
                        }
                    }
                } else {
                    fatalError("暂不支持超过 2 个 action")
                }
                
                actionIdx += 1
                lastButton = button
            }
        }
        
        @objc
        private func handleActionButtonTouchUpInside(_ button: ActionButton) {
            if let action = button.action {
                action.handler?(action)
                if action.allowAutoDismiss {
                    dismiss(completion: nil)
                }
            }
        }
    }
}
