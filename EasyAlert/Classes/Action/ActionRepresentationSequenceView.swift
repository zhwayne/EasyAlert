//
//  ActionRepresentationSequenceView.swift
//  EasyAlert
//
//  Created by iya on 2021/12/17.
//

import UIKit

final class ActionRepresentationSequenceView: UIControl {
    
    let contentView = ActionSeparatableSequenceView()
    
    private var representationView: ActionRepresentationView?
    
    private let feedback = UISelectionFeedbackGenerator()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        resetRepresentationView()
        handleTracking(touch, with: event, isTracking: false)
        return super.beginTracking(touch, with: event)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        defer { representationView = nil }
        super.endTracking(touch, with: event)
        if let representationView, representationView.isHighlighted {
            representationView.isHighlighted = false
            representationView.sendActions(for: .touchUpInside)
        }
    }
    
    override func cancelTracking(with event: UIEvent?) {
        defer { resetRepresentationView() }
        super.cancelTracking(with: event)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        handleTracking(touch, with: event, isTracking: true)
        return super.continueTracking(touch, with: event)
    }
    
    private func handleTracking(_ touch: UITouch, with event: UIEvent?, isTracking: Bool) {
        guard let targetViews = contentView.findActionRepresentationViews() else {
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
