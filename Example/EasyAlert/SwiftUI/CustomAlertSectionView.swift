//
//  CustomAlertSectionView.swift
//

import SwiftUI
import EasyAlert
import UIKit

struct CustomAlertSectionView: View {
  var body: some View {
    Section("自定义弹窗") {
      Button {
        let alert = MessageAlert(title: alertTitle, message: message)
        alert.backdrop.allowDismissWhenBackgroundTouch = true
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
        alert.backdrop.dimming = .blur(style: .dark, radius: 5)
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
        configuration.makeActionLayout = {
          MyAlertActionLayout()
        }
        configuration.makeActionView = { style in
          MyAlertActionView(style: style)
        }

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
  }
}

