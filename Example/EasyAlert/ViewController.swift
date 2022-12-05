//
//  ViewController.swift
//  EasyAlert
//
//  Created by 张尉 on 04/09/2022.
//  Copyright (c) 2022 张尉. All rights reserved.
//

import UIKit
import EasyAlert
import SwiftUI

class ViewController: UIViewController {
    
    private var tableView: UITableView!
    
    private var sections: [Section] = [
        .message(title: "消息弹框", items: [
            .systemAlert("iOS系统消息弹框"),
            .messageAlert("仿系统消息弹框"),
            .threeActions("3个按钮, 2秒后自动消失")
        ]),
        .customMessage(title: "自定义消息弹框", items: [
            .allowTapBackground("允许点击背景消失"),
            .effectBackground("模糊背景"),
            .leftAlignment("标题和内容左对齐"),
            .cornerRadius("自定义按钮UI和布局"),
            .attributedTitleAndMessage("支持富文本"),
        ]),
        .sheet(title: "ActionSheets", items: [
            .systemActionSheet("系统 ActionSheet")
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
        tableView.keyboardDismissMode = .onDrag
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
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
        case let .sheet(title, _): return title
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
            
        case let .systemActionSheet(title): cell.textLabel?.text = title
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
            alert.addAction(cancel)
            alert.addAction(ignore)
            alert.show(on: view)
            
        case .threeActions:
            let alert = MessageAlert(title: alertTitle, message: message)
            let cancel = Action(title: "取消", style: .cancel)
            let confirm = Action(title: "确定", style: .default)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.addActions([cancel, confirm, ignore])
            alert.callback = LiftcycleCallback(willShow: {
                print("Alert will show.")
            }, didShow: {
                print("Alert did show.")
            }, willDismiss: {
                print("Alert will dismiss.")
            }, didDismiss: {
                print("Alert did dismiss.")
            })
            alert.show(on: view)
            
            if #available(iOS 13.0, *) {
                Task {
                    try? await Task.sleep(nanoseconds:2_000_000_000)
                    await alert.dismiss()
                    print("Alert destroyed.")
                }
            }
            
        case .allowTapBackground:
            let alert = MessageAlert(title: alertTitle, message: message)
            alert.backgroundProvider.allowDismissWhenBackgroundTouch = true
            let cancel = Action(title: "取消", style: .cancel)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.addAction(cancel)
            alert.addAction(ignore)
            alert.show()

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
            alert.addAction(cancel)
            alert.addAction(ignore)
            alert.callback = LiftcycleCallback(didDismiss: {
                animator.stopAnimation(true)
            })
            alert.show()
            
        case .leftAlignment:
            var configuration = MessageAlert.Configuration()
            configuration.titleConfiguration.alignment = .left
            configuration.messageConfiguration.alignment = .left
            
            let alert = MessageAlert(title: alertTitle, message: message, configuration: configuration)
            let cancel = Action(title: "取消", style: .cancel)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.addAction(cancel)
            alert.addAction(ignore)
            alert.show()
            
        case .cornerRadius:
            
            var configuration = MessageAlert.Configuration()
            configuration.titleConfiguration.alignment = .left
            configuration.messageConfiguration.alignment = .left
            configuration.actionLayout = MyActionLayout()
            configuration.actionViewType = MyActionView.self
            
            let alert = MessageAlert(title: alertTitle, message: message, configuration: configuration)
            let cancel = Action(title: "取消", style: .cancel)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.addAction(cancel)
            alert.addAction(ignore)
            alert.show()
            
        case .attributedTitleAndMessage:
            var range = (alertTitle as NSString).range(of: "Meizu-0D23-5G")
            let attrTitle = NSMutableAttributedString(string: alertTitle)
            let titleParagraphStyle = NSMutableParagraphStyle()
            attrTitle.addAttribute(.foregroundColor, value: UIColor.systemPurple, range: range)
            
            range = NSRange(location: 0, length: alertTitle.count)
            titleParagraphStyle.lineHeightMultiple = 1.1
            titleParagraphStyle.alignment = .center
            attrTitle.addAttribute(.paragraphStyle, value: titleParagraphStyle.copy(), range: range)
            
            range = (message as NSString).range(of: "iCloud")
            let attrMessage = NSMutableAttributedString(string: message)
            attrMessage.addAttribute(.foregroundColor, value: UIColor.white, range: range)
            attrMessage.addAttribute(.backgroundColor, value: UIColor.orange, range: range)
            
            range = NSRange(location: 0, length: message.count)
            let messageParagraphStyle = NSMutableParagraphStyle()
            messageParagraphStyle.lineHeightMultiple = 1.05
            messageParagraphStyle.alignment = .center
            attrMessage.addAttribute(.paragraphStyle, value: messageParagraphStyle.copy(), range: range)
            
            let alert = MessageAlert(title: attrTitle, message: attrMessage)
            let cancel = Action(title: "取消", style: .cancel)
            let ignore = Action(title: "忽略", style: .destructive)
            alert.addAction(cancel)
            alert.addAction(ignore)
            alert.show()
            
        case .systemActionSheet:
            print("todo")
        }
    }
}
