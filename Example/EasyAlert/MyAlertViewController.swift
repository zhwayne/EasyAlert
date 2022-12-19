//
//  MyAlertViewController.swift
//  EasyAlert_Example
//
//  Created by iya on 2022/12/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EasyAlert

class MyAlertNavigationController: UINavigationController, AlertCustomizable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class MyAlertViewController: UIViewController, AlertCustomizable {
    
    deinit {
        print(#function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        // Do any additional setup after loading the view.
        
        let item = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleClose))
        navigationItem.rightBarButtonItem = item
        
        view.translatesAutoresizingMaskIntoConstraints = false

        view.heightAnchor.constraint(equalToConstant: 375).isActive = true
        
        preferredContentSize
    }
    
    @objc
    private func handleClose() {
        if let customizable = navigationController as? AlertCustomizable {
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
