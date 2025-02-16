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

class ActionGroupView: UIView, AlertCustomizable {
    
    var actions: [Action] = []
    
    private var actionLayout: ActionLayoutable
    
    private let customView: UIView?
    
    private let customController: UIViewController?
    
    var backgroundView: UIView {
        didSet {
            oldValue.removeFromSuperview()
            backgroundView.clipsToBounds = true
            backgroundView.frame = bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(backgroundView, at: 0)
        }
    }
    
    private let representationSequenceView = ActionRepresentationSequenceView()
    
    private lazy var separatorView = ActionVibrantSeparatorView()
    
    private let containerView = UIView()
    
    required init(content: AlertCustomizable?, actionLayout: ActionLayoutable) {
        self.actionLayout = actionLayout
        if #available(iOS 13.0, *) {
            self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        } else {
            // Fallback on earlier versions
            self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        }
        if let view = content as? UIView {
            self.customView = view
            self.customController = nil
        } else if let viewController = content as? UIViewController {
            self.customView = viewController.view
            self.customController = viewController
        } else {
            self.customView = nil
            self.customController = nil
        }

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
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        if let customView {
            if let customController, let alertContainerController {
                customController.willMove(toParent: alertContainerController)
                alertContainerController.addChild(customController)
                containerView.addSubview(customView)
                customController.didMove(toParent: alertContainerController)
            } else {
                containerView.addSubview(customView)
            }
            
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
    
    func updateLayout(interfaceOrientation: UIInterfaceOrientation) {
        representationSequenceView.separatableSequenceView.subviews.forEach {
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
        separatorView.isHidden = actionLayout.prefersSeparatorHidden
        let separatableSequenceView = representationSequenceView.separatableSequenceView
        actionLayout.layout(views: buttons, container: separatableSequenceView)
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
        if #available(iOS 13.0, *) {
            backgroundView.layer.cornerCurve = .continuous
        }
        backgroundView.layer.cornerRadius = radius
        let view = representationSequenceView.separatableSequenceView
        if (actions.count == 1 && actions[0].style == .cancel) || customView == nil {
            view.setCornerRadius(radius)
        } else {
            view.setCornerRadius(radius, corners: [.bottomLeft, .bottomRight])
        }
    }
    
    private var alertContainerController: AlertContainerController? {
        for view in sequence(first: superview, next: { $0?.superview }) {
            if let responder = view?.next as? AlertContainerController {
                return responder
            }
        }
        return nil
    }
}

extension ActionGroupView: LiftcycleListener {
    
    func willShow() {
        if let customController {
            customController.beginAppearanceTransition(true, animated: true)
        }
    }
    
    func didShow() {
        if let customController {
            customController.endAppearanceTransition()
        }
    }
    
    func willDismiss() {
        if let customController {
            customController.beginAppearanceTransition(false, animated: true)
        }
    }
    
    func didDismiss() {
        if let customController {
            customController.endAppearanceTransition()
        }
    }
}
