//
//  AlertContainerViewController.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import UIKit

final class AlertContainerViewController: UIViewController {
    
    weak var weakAlert: Alert?
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool { false }
    
    private var activeRepresentationView: (any UIControl & RepresentationMarking)?
    
    private let feedback = UISelectionFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Fix for child controllers not receiving an update on safe area insets
        // when they're partially not showing
        for child in children {
            let preInsets = child.additionalSafeAreaInsets
            child.additionalSafeAreaInsets = view.safeAreaInsets
            child.additionalSafeAreaInsets = preInsets
        }
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
        guard let targetViews = view.findActionRepresentationViews() else {
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
        for view in targetViews where view !== touched && view.isHighlighted {
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
    
    fileprivate func findActionRepresentationViews() -> [any UIControl & RepresentationMarking]? {
        findSubviews(ofType: (any UIControl & RepresentationMarking).self)
    }
    
    func findSubviews<T>(ofType: T.Type) -> [T]? {
        guard subviews.isEmpty == false else { return nil }
        var allViews = [T]()
        for view in subviews where view is T {
            allViews.append(view as! T)
        }
        if allViews.isEmpty {
            for view in subviews {
                if let buttons = view.findSubviews(ofType: T.self) {
                    allViews.append(contentsOf: buttons)
                }
            }
        }
        return allViews
    }
}
