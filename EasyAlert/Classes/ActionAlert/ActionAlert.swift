//
//  ActionAlert.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/7/28.
//

import UIKit

open class ActionAlert: Alert {
    
    let alertContentView: ContentView
    
    let configuration: ActionAlertConfiguration
    
    public required init(customView: CustomizedView,
                         configuration: ActionAlertConfiguration = ActionAlert.Configuration.global) {
        self.configuration = configuration
        alertContentView = ContentView(customView: customView)
        super.init(customView: alertContentView)
        alertContentView.actionLayout = self.configuration.actionLayout
        let transitionCoordinator = ActionAlertTransitionCoordinator()
        transitionCoordinator.alertCustomView = alertContentView
        self.transitionCoordinator = transitionCoordinator
    }
    
    open override func willLayoutContainer() {
        super.willLayoutContainer()
        alertContentView.setCornerRadius(configuration.cornerRadius)
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
            action.view = configuration.actionViewType.init(style: action.style)
            action.view?.title = action.title
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
        
        private var representationView: ActionRepresentationView?
        
        private let feedback = UISelectionFeedbackGenerator()
                
        private lazy var contentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 1 / UIScreen.main.scale
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
            backgroundView.frame = bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
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
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            contentStackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            contentStackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateLayout(interfaceOrientation: UIInterfaceOrientation, width: Width) {
            actionContainerView.contentView.subviews.forEach {
                $0.removeFromSuperview()
            }
            guard !actions.isEmpty else { return }
            
            // FIXME: 这里需要一套高效的diff方式，避免不必要的重新构建view。
            let buttons = actions.map { action -> UIView in
                if let representationView = action.representationView {
                    return representationView
                }
                
                let button = ActionRepresentationView()
                defer { action.representationView = button }
                button.action = action
                button.isEnabled = action.isEnabled
                let selector = #selector(handleActionButtonTouchUpInside(_:))
                button.removeTarget(self, action: selector, for: .touchUpInside)
                button.addTarget(self, action: selector, for: .touchUpInside)
                return button
            }
            actionLayout.layout(actionViews: buttons, container: actionContainerView.contentView)
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
            actionContainerView.contentView.setCornerRadius(radius)
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            resetRepresentationView()
            if let touch = touches.first {
                handleTracking(touch, with: event, isTracking: false)
            }
            super.touchesBegan(touches, with: event)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            defer { representationView = nil }
            if let representationView, representationView.isHighlighted {
                representationView.isHighlighted = false
                representationView.sendActions(for: .touchUpInside)
            }
            super.touchesEnded(touches, with: event)
        }
    
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            resetRepresentationView()
            super.touchesCancelled(touches, with: event)
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first {
                handleTracking(touch, with: event, isTracking: true)
            }
            super.touchesMoved(touches, with: event)
        }
        
        private func handleTracking(_ touch: UITouch, with event: UIEvent?, isTracking: Bool) {
            guard let targetViews = actionContainerView.contentView.findActionRepresentationViews() else {
                resetRepresentationView()
                return
            }
            guard let touched = targetViews.first(where: { view in
                let point = touch.location(in: view)
                return view.point(inside: point, with: event)
            }) else {
                resetRepresentationView()
                return
            }
            representationView = touched
            
            if !touched.isHighlighted {
                touched.isHighlighted = true
                if isTracking {
                    feedback.selectionChanged()
                }
            }
            for view in targetViews where view != touched && view.isHighlighted {
                view.isHighlighted = false
            }
        }
        
        private func resetRepresentationView() {
            if let representationView, representationView.isHighlighted {
                representationView.isHighlighted = false
            }
            representationView = nil
        }
    }
}

extension UIView {
    
    fileprivate func findActionRepresentationViews() -> [ActionRepresentationView]? {
        guard subviews.isEmpty == false else { return nil }
        var allButtons = [UIView]()
        for view in subviews where view is ActionRepresentationView{
            if (view as! ActionRepresentationView).isEnabled {
                allButtons.append(view)
            }
        }
        if allButtons.isEmpty {
            for view in subviews {
                if let buttons = view.findActionRepresentationViews() {
                    allButtons.append(contentsOf: buttons)
                }
            }
        }
        return (allButtons as! [ActionRepresentationView])
    }
}
