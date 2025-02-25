//
//  MyAlertViewController.swift
//  EasyAlert_Example
//
//  Created by iya on 2022/12/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EasyAlert

class MyAlertNavigationController: UINavigationController, AlertContent {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
    }
}

class MyAlertViewController: UIViewController, AlertContent {
    
    deinit {
        print(#function)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        // Do any additional setup after loading the view.
        
//        let item = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleClose))
//        navigationItem.rightBarButtonItem = item
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = UIColor.systemGreen
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        saveButton.clipsToBounds = true
        saveButton.layer.cornerRadius = 24
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 300).isActive = true
        saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        saveButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    @objc
    private func handleClose() {
        if let customizable = navigationController as? AlertContent {
            customizable.dismiss(completion: nil);
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(#function)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let viewController = MyAlertViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
