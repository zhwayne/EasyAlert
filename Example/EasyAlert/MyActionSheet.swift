//
//  MyActionSheet.swift
//  EasyAlert_Example
//
//  Created by iya on 2022/12/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EasyAlert

class MyActionSheet: ActionSheet {

    private class ContentView: UIView, AlertContent {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let view = UIView()
            view.backgroundColor = .systemPink
            addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            view.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
            view.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            
            view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    required init() {
        super.init(content:  ContentView())
    }
}
