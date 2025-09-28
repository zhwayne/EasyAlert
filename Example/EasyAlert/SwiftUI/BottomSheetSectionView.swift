//
//  BottomSheetSectionView.swift
//

import SwiftUI
import EasyAlert
import UIKit

struct BottomSheetSectionView: View {
  var body: some View {
    Section("底部弹窗") {
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
        let sheet = ActionSheet()
        let cancel = Action(title: "取消", style: .cancel)
        let confirm = Action(title: "确定", style: .default)
        let ignore = Action(title: "忽略", style: .destructive)
        sheet.addActions([cancel, confirm, ignore])
        sheet.show()
      } label: {
        Text("仿系统 ActionSheet")
      }

      Button {
        var configuration = ActionSheet.Configuration.global
        configuration.cancelSpacing = 0
        configuration.makeActionView = { style in
          MySheetActionView(style: style)
        }
        configuration.makeActionLayout = {
          MySheetActionLayout()
        }
        configuration.layoutGuide.contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let sheet = ActionSheet(configuration: configuration)
        let cancel = Action(title: "取消", style: .cancel)
        let confirm = Action(title: "确定", style: .default)
        let ignore = Action(title: "忽略", style: .destructive)
        sheet.addActions([cancel, confirm, ignore])
        sheet.show()
      } label: {
        Text("自定义 ActionSheet")
      }
    }
  }
}

