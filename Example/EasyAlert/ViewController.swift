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
    
    private var tableView: UITableView!
    
    private var sections: [Section] = [
        .message(title: "消息弹框", items: [
            .systemAlert("iOS系统消息弹框"),
            .messageAlert("仿系统消息弹框"),
            .threeActions("3个按钮")
        ]),
        .customMessage(title: "自定义消息弹框", items: [
            .allowTapBackground("允许点击背景消失"),
            .effectBackground("模糊背景"),
            .leftAlignment("标题和内容左对齐"),
            .cornerRadius("自定义按钮UI和布局"),
            .attributedTitleAndMessage("支持富文本"),
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) { view.backgroundColor = .systemBackground } else {
            view.backgroundColor = .white
        }
        
        if #available(iOS 13.0, *) {
            tableView = UITableView(frame: .zero, style: .insetGrouped)
        } else {
            tableView = UITableView(frame: .zero, style: .grouped)
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case let .message(title, _): return title
        case let .customMessage(title, _):  return title
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.accessoryType = .disclosureIndicator
        let item = sections[indexPath.section].items[indexPath.row]
        
        switch item {
        case let .systemAlert(title): cell.textLabel?.text = title
        case let .messageAlert(title): cell.textLabel?.text = title
        case let .threeActions(title): cell.textLabel?.text = title
        case let .allowTapBackground(title): cell.textLabel?.text = title
        case let .effectBackground(title): cell.textLabel?.text = title
        case let .leftAlignment(title): cell.textLabel?.text = title
        case let .cornerRadius(title): cell.textLabel?.text = title
        case let .attributedTitleAndMessage(title): cell.textLabel?.text = title
        }
        return cell
    }
    
    var alertTitle: String {
        "要移除无线局域网“Meizu-0D23-5G”吗？"
    }
    
    var message: String {
        "您的设备和其他使用iCloud钥匙串的设备将不再加入此无线局域网络。"
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]
        
        switch item {
        case .systemAlert:
            let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            let ignore = UIAlertAction(title: "忽略", style: .destructive)
            alertController.addAction(cancel)
            alertController.addAction(ignore)
            present(alertController, animated: true)
            
        case .messageAlert:
            let alert = MessageAlert(title: alertTitle, message: message)
            let cancel = Action(title: "取消", style: .cancel)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.add(action: cancel)
            alert.add(action: ignore)
            alert.show(in: view)
            
        case .threeActions:
            let alert = MessageAlert(title: alertTitle, message: message)
            let cancel = Action(title: "取消", style: .cancel)
            let confirm = Action(title: "确定", style: .default)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.add(action: cancel)
            alert.add(action: confirm)
            alert.add(action: ignore)
            alert.show(in: view)
            
        case .allowTapBackground:
            let alert = MessageAlert(title: alertTitle, message: message)
            alert.backgroundProvider.allowDismissWhenBackgroundTouch = true
            let cancel = Action(title: "取消", style: .cancel)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.add(action: cancel)
            alert.add(action: ignore)
            alert.show(in: view)
            
        case .effectBackground:
            let alert = MessageAlert(title: alertTitle, message: message)
            let effectView = UIVisualEffectView()
            let animator = UIViewPropertyAnimator(duration: 0, curve: .linear) {
                effectView.effect = UIBlurEffect(style: .regular)
            }
            animator.fractionComplete = 0.2
            alert.backgroundProvider.dimming = .view(effectView)
            let cancel = Action(title: "取消", style: .cancel)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.add(action: cancel)
            alert.add(action: ignore)
            alert.callback = LiftcycleCallback(didDismiss: {
                animator.stopAnimation(true)
            })
            alert.show(in: view)
            
        case .leftAlignment:
            var titleConfig = MessageAlert.titleConfig
            titleConfig.alignment = .left
            
            var messageConfig = MessageAlert.messageConfig
            messageConfig.alignment = .left
            
            let alert = MessageAlert(title: alertTitle, message: message, titleConfig: titleConfig, messageConfig: messageConfig)
            let cancel = Action(title: "取消", style: .cancel)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.add(action: cancel)
            alert.add(action: ignore)
            alert.show(in: view)
            
        case .cornerRadius:
            var config = ActionAlert.config
            config.actionLayout = MyActionLayout()
            config.actionViewType = MyActionView.self
            
            var titleConfig = MessageAlert.titleConfig
            titleConfig.alignment = .left
            
            var messageConfig = MessageAlert.messageConfig
            messageConfig.alignment = .justified
            
            let alert = MessageAlert(title: alertTitle, message: message, config: config, titleConfig: titleConfig, messageConfig: messageConfig)
            let cancel = Action(title: "取消", style: .cancel)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.add(action: cancel)
            alert.add(action: ignore)
            alert.show(in: view)
            
        case .attributedTitleAndMessage:
            var range = (alertTitle as NSString).range(of: "Meizu-0D23-5G")
            let attrTitle = NSMutableAttributedString(string: alertTitle)
            attrTitle.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: range)
            
            range = (message as NSString).range(of: "iCloud")
            let attrMessage = NSMutableAttributedString(string: message)
            attrMessage.addAttribute(.foregroundColor, value: UIColor.white, range: range)
            attrMessage.addAttribute(.backgroundColor, value: UIColor.orange, range: range)
            
            let alert = MessageAlert(title: attrTitle, message: attrMessage)
            let cancel = Action(title: "取消", style: .cancel)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.add(action: cancel)
            alert.add(action: ignore)
            alert.show(in: view)
        }
    }
}

//class SheetContent: Alert.CustomizedView {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        backgroundColor = .orange
//
//        let switcher = UISwitch()
//        addSubview(switcher)
//
//        switcher.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(64)
//            make.centerX.equalToSuperview()
//            if #available(iOS 11.0, *) {
//                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-217)
//            } else {
//                // Fallback on earlier versions
//                make.bottom.equalToSuperview().offset(-217)
//            }
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}


