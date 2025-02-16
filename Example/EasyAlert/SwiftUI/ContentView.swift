//
//  ContentView.swift
//  EasyAlert_Example
//
//  Created by W on 2025/2/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI
import EasyAlert

struct ContentView: View {
    
    var alertTitle: String {
        "要移除无线局域网“Meizu-0D23-5G”吗？"
    }
    
    var message: String {
        "您的设备和其他使用iCloud钥匙串的设备将不再加入此无线局域网络。"
    }
    
    
    var body: some View {
        List {
            Section {
                Button {
                    let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "取消", style: .cancel)
                    let ignore = UIAlertAction(title: "忽略", style: .destructive)
                    alertController.addAction(cancel)
                    alertController.addAction(ignore)
                    rootViewController.present(alertController, animated: true)
                } label: {
                    Text("iOS系统消息弹框")
                }
                Button {
                    let alert = MessageAlert(title: alertTitle, message: message)
                    alert.backdropProvider.allowDismissWhenBackgroundTouch = true
                    let cancel = Action(title: "取消", style: .cancel)
                    let ignore = Action(title: "忽略", style: .destructive)
                    alert.addAction(cancel)
                    alert.addAction(ignore)
                    alert.show()
                    
                } label: {
                    Text("仿系统消息弹框")
                }
                Button {
                    let alert = MessageAlert(title: alertTitle, message: message)
                    let cancel = Action(title: "取消", style: .cancel)
                    let confirm = Action(title: "确定", style: .default)
                    let ignore = Action(title: "忽略", style: .destructive)
                    alert.addActions([cancel, confirm, ignore])
                    alert.addListener(LiftcycleCallback(willShow: {
                        print("Alert will show.")
                    }, didShow: {
                        print("Alert did show.")
                    }, willDismiss: {
                        print("Alert will dismiss.")
                    }, didDismiss: {
                        print("Alert did dismiss.")
                    }))
                    alert.show()
                    
                    Task {
                        try? await Task.sleep(nanoseconds:2_000_000_000)
                        await alert.dismiss()
                        print("Alert destroyed.")
                    }
                } label: {
                    Text("3个按钮, 2秒后自动消失")
                }
            }
            
            Section {
                Button {
                    let alert = MessageAlert(title: alertTitle, message: message)
                    alert.backdropProvider.allowDismissWhenBackgroundTouch = true
                    let cancel = Action(title: "取消", style: .cancel)
                    let ignore = Action(title: "忽略", style: .destructive)
                    alert.addAction(cancel)
                    alert.addAction(ignore)
                    alert.show()
                } label: {
                    Text("允许点击背景消失")
                }
                Button {
                    let alert = MessageAlert(title: alertTitle, message: message)
                    if #available(iOS 13.0, *) {
                        alert.backdropProvider.dimming = .blur(style: .systemThinMaterialDark, level: 0.6)
                    } else {
                        // Fallback on earlier versions
                        alert.backdropProvider.dimming = .blur(style: .dark, level: 0.6)
                    }
                    let cancel = Action(title: "取消", style: .cancel)
                    let ignore = Action(title: "忽略", style: .destructive)
                    alert.addAction(ignore)
                    alert.addAction(cancel)
                    alert.show()
                    
                } label: {
                    Text("模糊背景")
                }
                Button {
                    var configuration = MessageAlert.Configuration.global
                    configuration.titleConfiguration.alignment = .left
                    configuration.messageConfiguration.alignment = .left
                    
                    let alert = MessageAlert(title: alertTitle, message: message, configuration: configuration)
                    let cancel = Action(title: "取消", style: .cancel)
                    let ignore = Action(title: "忽略", style: .destructive)
                    alert.addAction(cancel)
                    alert.addAction(ignore)
                    alert.show()
                } label: {
                    Text("标题和内容左对齐")
                }
                Button {
                    var configuration = MessageAlert.Configuration.global
                    configuration.titleConfiguration.alignment = .left
                    configuration.messageConfiguration.alignment = .left
                    configuration.actionLayoutType = MyAlertActionLayout.self
                    configuration.actionViewType = MyAlertActionView.self
                    
                    let alert = MessageAlert(title: alertTitle, message: message, configuration: configuration)
                    let cancel = Action(title: "取消", style: .cancel)
                    let ignore = Action(title: "忽略", style: .destructive)
                    alert.addAction(cancel)
                    alert.addAction(ignore)
                    alert.show()
                } label: {
                    Text("自定义按钮UI和布局")
                }
                Button {
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
                } label: {
                    Text("支持富文本")
                }
            }
            
            Section {
                Button {
                    let alert = Alert {
                        VStack(spacing: 8) {
                            Text(alertTitle)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color.orange)
                            Text(message)
                                .font(.system(size: 13))
                                .lineSpacing(4)
                        }
                        .multilineTextAlignment(.center)
                        .frame(width: 270)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    alert.backdropProvider.allowDismissWhenBackgroundTouch = true
                    alert.show()
                } label: {
                    Text("显示 SwiftUI View")
                }
                Button {
                    let alert = ActionAlert(content: EasyAlertHostingController(rootView: HStack {
                        VStack(spacing: 8) {
                            Text(alertTitle)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color.orange)
                            Text(message)
                                .font(.system(size: 13))
                                .lineSpacing(4)
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(width: 270)
                    }))
                    let cancel = Action(title: "取消", style: .cancel)
                    let ignore = Action(title: "忽略", style: .destructive)
                    alert.addAction(cancel)
                    alert.addAction(ignore)
                    alert.show()
                } label: {
                    Text("显示带按钮的 SwiftUI View")
                }
            }
            
            Section {
                Button {
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let cancel = UIAlertAction(title: "取消", style: .cancel)
                    let confirm = UIAlertAction(title: "确定", style: .default)
                    let ignore = UIAlertAction(title: "忽略", style: .destructive)
                    alertController.addAction(cancel)
                    alertController.addAction(confirm)
                    alertController.addAction(ignore)
                    rootViewController.present(alertController, animated: true)
                } label: {
                    Text("系统 ActionSheet")
                }
                Button {
                    var configuration = ActionSheet.Configuration.global
                    configuration.cancelSpacing = 0
                    configuration.actionViewType = MySheetActionView.self
                    configuration.actionLayoutType = MySheetActionLayout.self
                    configuration.layoutGuide.contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                    
                    let sheet = ActionSheet(configuration: configuration)
                    let cancel = Action(title: "取消", style: .cancel)
                    let confirm = Action(title: "确定", style: .default)
                    let ignore = Action(title: "忽略", style: .destructive)
                    sheet.addActions([cancel, confirm, ignore])
                    sheet.show()
                    
                } label: {
                    Text("仿系统 ActionSheet")
                }
            }
            
            Section {
                Button {
                    Toast.show(message)
                } label: {
                    Text("显示 Toast")
                }
            }
        }
    }
}

var rootViewController: UIViewController {
    UIApplication.shared.delegate!.window!!.rootViewController!
}

#Preview {
    ContentView()
}
