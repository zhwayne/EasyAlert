//
//  ActionGroupView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/6.
//

import UIKit

class ActionGroupView: Alert.CustomizedView {
    
    var actionLayout: ActionLayoutable
    
    var actions: [Action] = []
    
    let customView: Alert.CustomizedView
    
    private let backgroundView: UIVisualEffectView
    
    private let representationSequenceView = ActionRepresentationSequenceView()
    
    private var activeRepresentationView: ActionCustomViewRepresentationView?
    
    private lazy var separatorView = ActionVibrantSeparatorView()
    
    private let feedback = UISelectionFeedbackGenerator()
    
    private let groupView = UIView()
    
    required init(customView: Alert.CustomizedView, actionLayout: ActionLayoutable) {
        self.actionLayout = actionLayout
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
        
        groupView.frame = bounds
        groupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(groupView)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        
        customView.removeFromSuperview()
        groupView.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.deactivate(customView.constraints)
        customView.topAnchor.constraint(equalTo: groupView.topAnchor).isActive = true
        customView.leftAnchor.constraint(equalTo: groupView.leftAnchor).isActive = true
        customView.rightAnchor.constraint(equalTo: groupView.rightAnchor).isActive = true
        customView.widthAnchor.constraint(equalTo: groupView.widthAnchor).isActive = true
        let customBottomConstraint = customView.bottomAnchor.constraint(equalTo: groupView.bottomAnchor)
        customBottomConstraint.priority = .defaultHigh - 1
        customBottomConstraint.isActive = true
        
        if !actions.isEmpty {
            separatorView.removeFromSuperview()
            groupView.addSubview(separatorView)
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.topAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
            separatorView.centerXAnchor.constraint(equalTo: groupView.centerXAnchor).isActive = true
            separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
            separatorView.widthAnchor.constraint(equalTo: groupView.widthAnchor).isActive = true
            separatorView.setContentHuggingPriority(.required, for: .vertical)
            
            representationSequenceView.removeFromSuperview()
            groupView.addSubview(representationSequenceView)
            representationSequenceView.translatesAutoresizingMaskIntoConstraints = false
            representationSequenceView.topAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
            representationSequenceView.centerXAnchor.constraint(equalTo: groupView.centerXAnchor).isActive = true
            representationSequenceView.widthAnchor.constraint(equalTo: groupView.widthAnchor).isActive = true
            representationSequenceView.bottomAnchor.constraint(equalTo: groupView.bottomAnchor).isActive = true
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayout(interfaceOrientation: UIInterfaceOrientation, width: Width) {
        representationSequenceView.contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        guard !actions.isEmpty else { return }
        
        let buttons = actions.map { action -> UIView in
            if let representationView = action.representationView {
                return representationView
            }
            
            let button = ActionCustomViewRepresentationView()
            defer { action.representationView = button }
            button.action = action
            button.isEnabled = action.isEnabled
            let selector = #selector(handleActionButtonTouchUpInside(_:))
            button.removeTarget(self, action: selector, for: .touchUpInside)
            button.addTarget(self, action: selector, for: .touchUpInside)
            return button
        }
        if actionLayout is AlertActionLayout {
            separatorView.isHidden = false
        } else {
            separatorView.isHidden = true
        }
        actionLayout.layout(actionViews: buttons, container: representationSequenceView.contentView)
    }
    
    @objc
    private func handleActionButtonTouchUpInside(_ button: ActionCustomViewRepresentationView) {
        if let action = button.action {
            action.handler?(action)
            if action.allowAutoDismiss {
                dismiss(completion: nil)
            }
        }
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        backgroundView.layer.cornerRadius = radius
        representationSequenceView.contentView.setCornerRadius(radius)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetRepresentationView()
        if let touch = touches.first {
            handleTracking(touch, with: event, isTracking: false)
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer { activeRepresentationView = nil }
        if let activeRepresentationView, activeRepresentationView.isHighlighted {
            activeRepresentationView.isHighlighted = false
            activeRepresentationView.sendActions(for: .touchUpInside)
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
        guard let targetViews = representationSequenceView.contentView.findActionRepresentationViews() else {
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
        activeRepresentationView = touched
        for view in targetViews where view != touched && view.isHighlighted {
            view.isHighlighted = false
        }
        if !touched.isHighlighted {
            touched.isHighlighted = true
            if isTracking {
                feedback.selectionChanged()
            }
        }
    }
    
    private func resetRepresentationView() {
        if let activeRepresentationView, activeRepresentationView.isHighlighted {
            activeRepresentationView.isHighlighted = false
        }
        activeRepresentationView = nil
    }
}

extension UIView {
    
    fileprivate func findActionRepresentationViews() -> [ActionCustomViewRepresentationView]? {
        findSubviews(ofClass: ActionCustomViewRepresentationView.self)
    }
    
    func findSubviews<T: UIView>(ofClass: T.Type) -> [T]? {
        guard subviews.isEmpty == false else { return nil }
        var allViews = [T]()
        for view in subviews where view is T {
            allViews.append(view as! T)
        }
        if allViews.isEmpty {
            for view in subviews {
                if let buttons = view.findSubviews(ofClass: T.self) {
                    allViews.append(contentsOf: buttons)
                }
            }
        }
        return allViews
    }
}
