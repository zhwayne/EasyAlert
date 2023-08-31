//
//  AlertActionLayout.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/4.
//

import UIKit

struct AlertActionLayout: ActionLayoutable {
    
    var prefersSeparatorHidden: Bool { false }
    
    private let stackView: UIStackView
    
    private var constraints: [NSLayoutConstraint] = []
    
    init() {
        stackView = UIStackView()
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
        stackView.axis = actionViews.count <= 2 ? .horizontal : .vertical
        container.addSubview(stackView)
        
        constraints.append(stackView.topAnchor.constraint(equalTo: container.topAnchor))
        constraints.append(stackView.leftAnchor.constraint(equalTo: container.leftAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor))
        constraints.append(stackView.rightAnchor.constraint(equalTo: container.rightAnchor))
        
        if actionViews.count == 2 {
            let separator = container.verticalSeparator(at: 0)
            stackView.addSubview(separator)
            constraints.append(separator.topAnchor.constraint(equalTo: stackView.topAnchor))
            constraints.append(separator.bottomAnchor.constraint(equalTo: stackView.bottomAnchor))
            constraints.append(separator.centerXAnchor.constraint(equalTo: stackView.centerXAnchor))
            constraints.append(separator.widthAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale))
        } else {
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
}
