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
    
    let customView: Alert.CustomizedView?
    
    private let backgroundView: UIVisualEffectView
    
    private let representationSequenceView = ActionRepresentationSequenceView()
    
    private lazy var separatorView = ActionVibrantSeparatorView()
    
    private let containerView = UIView()
    
    required init(customView: Alert.CustomizedView?, actionLayout: ActionLayoutable) {
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
        addSubview(backgroundView)
        
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(containerView)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        if let customView {
            containerView.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            
            customView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            customView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            customView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            let customBottomConstraint = customView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            customBottomConstraint.priority = .defaultHigh - 1
            customBottomConstraint.isActive = true
        }
        
        if !actions.isEmpty {
            separatorView.removeFromSuperview()
            if let customView {
                containerView.addSubview(separatorView)
                separatorView.topAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
                separatorView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
                separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            }
            
            representationSequenceView.removeFromSuperview()
            containerView.addSubview(representationSequenceView)
            if customView != nil {
                representationSequenceView.topAnchor.constraint(equalTo: separatorView.bottomAnchor).isActive = true
            } else {
                representationSequenceView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            }
            representationSequenceView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            representationSequenceView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            representationSequenceView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
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
//        if actionLayout is AlertActionLayout || actionLayout is SheetActionLayout {
//            separatorView.isHidden = false
//        } else {
//            separatorView.isHidden = true
//        }
        separatorView.isHidden = actionLayout.prefersSeparatorHidden
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
}
