//
//  ViewController.swift
//  EasyAlert
//
//  Created by 张尉 on 04/09/2022.
//  Copyright (c) 2022 张尉. All rights reserved.
//

import UIKit
import EasyAlert

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            view.backgroundColor = .white
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleTap(_ sender: Any) {
        let alert = MessageAlert(title: "快讯", message: "神迹全程回顾，记住这一刻！记住9秒83！记住苏炳添！[心] 这是封神之战，东京奥运会100米短跑半决赛，苏炳添以9秒83个人历史最佳成绩晋级决赛！")
        alert.backgroundProvider.allowDismissWhenBackgroundTouch = true
        let action = Action(title: "好的", style: .default)
        let cancel = Action(title: "取消", style: .cancel)
        alert.add(action: cancel)
        alert.add(action: action)
        alert.show(in: view)
        
        //        let alert = Sheet(customView: SheetContent(frame: .zero))
        //        alert.backgroundProvider.allowDismissWhenBackgroundTouch = true
        //        alert.show(in: view)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAlertContentTap(_:)))
//        alert.customView.addGestureRecognizer(tap)
    }
    
//    @objc func handleAlertContentTap(_ sender: UITapGestureRecognizer) {
//        guard let view = sender.view as? Alert.CustomizedView else { return }
//        view.dismiss {
//            debugPrint("did disappear")
//        }
//    }
}

class SheetContent: Alert.CustomizedView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .orange
        
        let switcher = UISwitch()
        addSubview(switcher)
        
        switcher.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-217)
            } else {
                // Fallback on earlier versions
                make.bottom.equalToSuperview().offset(-217)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


