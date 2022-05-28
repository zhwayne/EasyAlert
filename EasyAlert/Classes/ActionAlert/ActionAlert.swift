//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/28.
//

import UIKit
import SnapKit

open class ActionAlert: Alert {
    
    let alertCustomView: ActionAlertCustomView
    
    public var backgoundColor: UIColor? {
        get { alertCustomView.backgroundView.backgroundColor }
        set { alertCustomView.backgroundView.backgroundColor = newValue }
    }
    
    public var actionLayout: ActionLayoutable {
        get { alertCustomView.actionLayout }
        set { alertCustomView.actionLayout = newValue }
    }
        
    public override init(customView: CustomizedView) {
        alertCustomView = ActionAlertCustomView(customView: customView)
        super.init(customView: alertCustomView)
        let layout = ActionAlertLayout()
        layout.alertCustomView = alertCustomView
        self.layout = layout
        
//        if #available(iOS 13.0, *) {
//            backgoundColor = .systemBackground.withAlphaComponent(0.33)
//        } else {
//            backgoundColor = .white.withAlphaComponent(0.33)
//        }
    }    
}

extension ActionAlert: ActionAlertble {
    
    public func add(action: Action) {
        assert(isShowing == false)
        alertCustomView.actions.append(action)
        setViewForAction(action)
    }
    
    public func add(actions: [Action]) {
        assert(isShowing == false)
        alertCustomView.actions.append(contentsOf: actions)
        actions.forEach { setViewForAction($0) }
    }
    
    private func setViewForAction(_ action: Action) {
        if action.view == nil {
            action.view = ActionAlert.config.actionViewType.init(style: action.style)
            action.view.title = action.title
        }
    }
}

extension ActionAlert {
    
    final class ActionAlertCustomView: CustomizedView {
        
        fileprivate lazy var actionLayout: ActionLayoutable = ActionAlert.config.actionLayout
        
        var actions: [Action] = []
        
        let customView: CustomizedView
        
        let backgroundView: UIVisualEffectView
        
        lazy var actionContainerView = ActionContainerView()
                
        private lazy var contentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = -1 / UIScreen.main.scale
            return stackView
        }()
        
        required init(customView: CustomizedView) {
            if #available(iOS 13.0, *) {
                self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            } else {
                // Fallback on earlier versions
                self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
            }
            self.customView = customView
            backgroundView.clipsToBounds = true
            backgroundView.layer.cornerRadius = ActionAlert.config.cornerRadius
            if #available(iOS 13.0, *) {
                backgroundView.layer.cornerCurve = .continuous
            }
            super.init(frame: .zero)
            backgroundView.frame = frame
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(backgroundView)
        }
        
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            guard superview != nil else { return }
 
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
            
            actionContainerView.subviews.forEach {
                $0.removeFromSuperview()
            }
            let buttons = actions.map { action -> UIView in
                let button = ActionButton()
                button.action = action
                button.isEnabled = action.isEnabled
                let selector = #selector(handleActionButtonTouchUpInside(_:))
                button.removeTarget(self, action: selector, for: .touchUpInside)
                button.addTarget(self, action: selector, for: .touchUpInside)
                return button
            }
            
            actionLayout.layout(actionViews: buttons, container: actionContainerView)
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
