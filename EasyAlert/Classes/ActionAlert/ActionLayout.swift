//
//  ActionLayout.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/4.
//

import Foundation


extension ActionAlert {
    
    struct ActionLayout: ActionLayoutable {
        
        private let stackView: UIStackView
        
        init() {
            stackView = UIStackView()
            stackView.distribution = .fillEqually
            stackView.spacing = 1 / UIScreen.main.scale
        }
        
        func layout(actionViews: [UIView], container: UIView) {
            
            guard let container = container as? ActionSeparatableSequenceView else {
                return
            }
            
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            actionViews.forEach { stackView.addArrangedSubview($0) }
            stackView.axis = actionViews.count <= 2 ? .horizontal : .vertical
            container.addSubview(stackView)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            stackView.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
            stackView.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
            
            if actionViews.count == 2 {
                let horizontalSeparator = container.horizontalSeparator(at: 0)
                
                container.addSubview(horizontalSeparator)
                horizontalSeparator.translatesAutoresizingMaskIntoConstraints = false
                horizontalSeparator.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
                horizontalSeparator.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
                horizontalSeparator.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
                horizontalSeparator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
                
                let verticalSeparator = container.verticalSeparator(at: 0)
                container.addSubview(verticalSeparator)
                verticalSeparator.translatesAutoresizingMaskIntoConstraints = false
                verticalSeparator.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
                verticalSeparator.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
                verticalSeparator.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
                verticalSeparator.widthAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
            } else {
                actionViews.enumerated().forEach { (idx, button) in
                    let horizontalSeparator = container.horizontalSeparator(at: idx)
                    container.addSubview(horizontalSeparator)
                    horizontalSeparator.translatesAutoresizingMaskIntoConstraints = false
                    horizontalSeparator.topAnchor.constraint(equalTo: button.topAnchor).isActive = true
                    horizontalSeparator.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
                    horizontalSeparator.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
                    horizontalSeparator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
                }
            }
        }
    }
}
