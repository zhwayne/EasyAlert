//
//  SheetActionLayout.swift
//  EasyAlert
//
//  Created by iya on 2022/12/6.
//

import Foundation

struct SheetActionLayout: ActionLayoutable {
    
    var prefersSeparatorHidden: Bool { false }
    
    private let stackView: UIStackView
    
    init() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 1 / UIScreen.main.scale
    }

    func layout(actionViews: [UIView], container: UIView) {
        
        guard let container = container as? ActionSeparatableSequenceView else {
            return
        }
        
        stackView.subviews.forEach { $0.removeFromSuperview() }
        actionViews.forEach { stackView.addArrangedSubview($0) }
        container.addSubview(stackView)
        
        NSLayoutConstraint.deactivate(stackView.constraints)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        
        actionViews.enumerated().forEach { (idx, button) in
            if idx == 0 { return }
            let horizontalSeparator = container.horizontalSeparator(at: idx - 1)
            stackView.addSubview(horizontalSeparator)
            horizontalSeparator.translatesAutoresizingMaskIntoConstraints = false
            horizontalSeparator.topAnchor.constraint(equalTo: button.topAnchor, constant: -stackView.spacing).isActive = true
            horizontalSeparator.leftAnchor.constraint(equalTo: stackView.leftAnchor).isActive = true
            horizontalSeparator.rightAnchor.constraint(equalTo: stackView.rightAnchor).isActive = true
            horizontalSeparator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        }
    }
}
