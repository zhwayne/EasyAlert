//
//  ActionCustomViewRepresentationView.swift
//  EasyAlert
//
//  Created by 张尉 on 2021/8/2.
//

import UIKit

final class ActionCustomViewRepresentationView: UIControl {
        
    var action: Action? {
        didSet {
            oldValue?.view?.removeFromSuperview()
            if let view = action?.view {
                addSubview(view)
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            action?.view?.isHighlighted = isHighlighted
            // 寻找相邻的 separators
            var separatableSequenceView: ActionSeparatableSequenceView?
            for view in sequence(first: superview, next: { $0?.superview }) {
                if let view = view as? ActionSeparatableSequenceView {
                    separatableSequenceView = view
                    break
                }
            }
            guard let target = separatableSequenceView,
                  let separators = target.findSubviews(ofClass: ActionVibrantSeparatorView.self) else {
                return
            }
            
            separators.filter({ separator in
                let frame1 = target.convert(frame.insetBy(dx: -1, dy: -1), from: self.superview!)
                let frame2 = target.convert(separator.frame, from: separator.superview!)
                return frame1.intersects(frame2)
            }).forEach { separator in
                separator.alpha = isHighlighted ? 0 : 1
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            action?.view?.isEnabled = isEnabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return action?.view?.intrinsicContentSize ?? .zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let action, let view = action.view {
            view.frame = bounds
        }
    }
}
