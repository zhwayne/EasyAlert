//
//  SheetActionLayout.swift
//  EasyAlert
//
//  Created by iya on 2022/12/6.
//

import UIKit

struct SheetActionLayout: ActionLayoutable {
    
    var prefersSeparatorHidden: Bool { false }
    
    private let stackView: UIStackView
    
    private var constraints: [NSLayoutConstraint] = []
        
    init() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 1 / UIScreen.main.scale
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    mutating func layout(actionViews: [UIView], container: UIView) {
        
        guard let container = container as? ActionSeparatableSequenceView else {
            return
        }
        
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        defer { NSLayoutConstraint.activate(constraints) }
        
        stackView.subviews.forEach { $0.removeFromSuperview() }
        actionViews.forEach { stackView.addArrangedSubview($0) }
        container.addSubview(stackView)
       
        constraints.append(stackView.topAnchor.constraint(equalTo: container.topAnchor))
        constraints.append(stackView.leftAnchor.constraint(equalTo: container.leftAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor))
        constraints.append(stackView.rightAnchor.constraint(equalTo: container.rightAnchor))
        
        actionViews.enumerated().forEach { (idx, button) in
            if idx == 0 { return }
            let separator = container.horizontalSeparator(at: idx - 1)
            stackView.addSubview(separator)
            constraints.append(separator.topAnchor.constraint(equalTo: button.topAnchor, constant: -stackView.spacing))
            constraints.append(separator.leftAnchor.constraint(equalTo: stackView.leftAnchor))
            constraints.append(separator.rightAnchor.constraint(equalTo: stackView.rightAnchor))
            constraints.append(separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale))
        }
    }
}
