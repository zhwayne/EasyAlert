//
//  MessageAlertSectionView.swift
//

import SwiftUI
import EasyAlert
import UIKit

struct MessageAlertSectionView: View {
  var body: some View {
    Section("消息弹窗") {
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
        alert.addListener(LifecycleCallback(willShow: {
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
          try? await Task.sleep(nanoseconds: 2_000_000_000)
          await alert.dismiss()
          print("Alert destroyed.")
        }
      } label: {
        Text("3个按钮, 2秒后自动消失")
      }
    }
  }
}

