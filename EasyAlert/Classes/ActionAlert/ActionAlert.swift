//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/28.
//

import UIKit
import SnapKit

open class ActionAlert: Alert {
    
    let alertContentView: ContentView
    
    let config: Configuration
    
    public required init(customView: CustomizedView, config: Configuration? = nil) {
        self.config = config ?? ActionAlert.config
        alertContentView = ContentView(customView: customView)
        super.init(customView: alertContentView)
        alertContentView.actionLayout = self.config.actionLayout
        let transitionCoordinator = ActionAlertTransitionCoordinator()
        transitionCoordinator.alertCustomView = alertContentView
        self.transitionCoordinator = transitionCoordinator
    }
    
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        alertContentView.setCornerRadius(config.cornerRadius)
    }
}

extension ActionAlert: ActionAlertble {
    
    public func add(action: Action) {
        assert(isShowing == false)
        alertContentView.actions.append(action)
        setViewForAction(action)
    }
    
    public func add(actions: [Action]) {
        assert(isShowing == false)
        alertContentView.actions.append(contentsOf: actions)
        actions.forEach { setViewForAction($0) }
    }
    
    private func setViewForAction(_ action: Action) {
        if action.view == nil {
            action.view = config.actionViewType.init(style: action.style)
            action.view.title = action.title
        }
    }
}

extension ActionAlert {
    
    final class ContentView: CustomizedView {
        
        fileprivate var actionLayout: ActionLayoutable!
        
        var actions: [Action] = []
        
        let customView: CustomizedView
        
        let backgroundView: UIVisualEffectView
        
        let actionContainerView = ActionRepresentationSequenceView()
                
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
        
        func updateLayout(interfaceOrientation: UIInterfaceOrientation, width: Width) {
            actionContainerView.subviews.forEach {
                $0.removeFromSuperview()
            }
            guard !actions.isEmpty else { return }
            
            // FIXME: 这里需要一套高效的diff方式，避免不必要的重新构建view。
            let buttons = actions.map { action -> UIView in
                let button = ActionRepresentationView()
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
        private func handleActionButtonTouchUpInside(_ button: ActionRepresentationView) {
            if let action = button.action {
                action.handler?(action)
                if action.allowAutoDismiss {
                    dismiss(completion: nil)
                }
            }
        }
        
        func setCornerRadius(_ radius: CGFloat) {
            backgroundView.layer.cornerRadius = radius
            actionContainerView.setCornerRadius(radius)
        }
    }
}
