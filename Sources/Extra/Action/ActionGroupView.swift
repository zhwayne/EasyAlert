//
//  ActionGroupView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/6.
//

import UIKit

public enum PresentationBackgroundDomain {
    case normal
    case cancel
}

class ActionGroupView: UIView {
    
    var actions: [Action] = [] {
        didSet { hasActions = !actions.isEmpty }
    }
    
    private var hasActions: Bool = false {
        didSet {
            if hasActions != oldValue {
                relayoutRepresentationSequenceView()
            }
        }
    }
    
    private var actionLayout: ActionLayoutable
    
    private let customView: UIView?
    
    private var backgroundViewCornerRadius: CGFloat = 0
    var backgroundView: UIView? {
        didSet {
            guard backgroundView !== oldValue else { return }
            oldValue?.removeFromSuperview()
            if let backgroundView {
                backgroundView.clipsToBounds = true
                backgroundView.frame = bounds
                backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                insertSubview(backgroundView, at: 0)
                backgroundView.layer.cornerRadius = backgroundViewCornerRadius
                backgroundView.clipsToBounds = true
                if #available(iOS 13.0, *) {
                    backgroundView.layer.cornerCurve = .continuous
                }
            }
        }
    }
    
    private var representationSequenceView: ActionRepresentationSequenceView?
    private var separatorView: ActionVibrantSeparatorView?
    private let containerView = UIView()
    
    required init(customView: UIView?, actionLayout: ActionLayoutable) {
        self.customView = customView
        self.actionLayout = actionLayout

        super.init(frame: .zero)
        
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(containerView)
        
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
    }
    
    private func relayoutRepresentationSequenceView() {
        separatorView?.removeFromSuperview()
        representationSequenceView?.removeFromSuperview()
        
        if hasActions {
            separatorView = separatorView ?? ActionVibrantSeparatorView()
            representationSequenceView = representationSequenceView ?? ActionRepresentationSequenceView()
            separatorView!.removeFromSuperview()
            if let customView {
                containerView.addSubview(separatorView!)
                separatorView!.topAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
                separatorView!.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                separatorView!.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
                separatorView!.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            }
            
            
            containerView.addSubview(representationSequenceView!)
            if customView != nil {
                representationSequenceView!.topAnchor.constraint(equalTo: separatorView!.bottomAnchor).isActive = true
            } else {
                representationSequenceView!.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            }
            representationSequenceView!.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            representationSequenceView!.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            representationSequenceView!.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            
        } else {
            separatorView = nil
            representationSequenceView = nil
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayout(interfaceOrientation: UIInterfaceOrientation) {
        guard let representationSequenceView else { return }
        representationSequenceView.separatableSequenceView.subviews.forEach { $0.removeFromSuperview() }
        guard !actions.isEmpty else { return }
        let buttons = getButtons(for: actions)
        separatorView?.isHidden = actionLayout.prefersSeparatorHidden
        let separatableSequenceView = representationSequenceView.separatableSequenceView
        actionLayout.layout(views: buttons, container: separatableSequenceView)
    }
    
    private func getButtons(for actions: [Action]) -> [UIView] {
        actions.map { action -> UIView in
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
        backgroundViewCornerRadius = radius
        backgroundView?.layer.cornerRadius = radius
        backgroundView?.clipsToBounds = true
        if #available(iOS 13.0, *) {
            backgroundView?.layer.cornerCurve = .continuous
        }
        if let view = representationSequenceView?.separatableSequenceView {
            if (actions.count == 1 && actions[0].style == .cancel) || customView == nil {
                view.setCornerRadius(radius)
            } else {
                view.setCornerRadius(radius, corners: [.bottomLeft, .bottomRight])
            }
        }
    }
}
