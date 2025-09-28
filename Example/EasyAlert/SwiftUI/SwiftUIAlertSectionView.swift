//
//  SwiftUIAlertSectionView.swift
//

import SwiftUI
import EasyAlert
import UIKit

struct SwiftUIAlertSectionView: View {
  @Binding var showCustomAlert: Bool
  @Binding var showSelfAsAlert: Bool

  var body: some View {
    Section("支持 SwiftUI") {
      Button {
        let content = AlertHostingController { alert in
          VStack(spacing: 8) {
            Text(alertTitle)
              .font(.system(size: 17, weight: .semibold))
              .foregroundColor(Color.orange)
            Text(message)
              .font(.system(size: 13))
              .lineSpacing(4)
            HStack(spacing: 16) {
              Button {
                alert?.dismiss()
              } label: {
                Text("取消")
                  .font(.system(size: 17, weight: .medium))
                  .frame(maxWidth: .infinity)
                  .frame(height: 44)
                  .background(Color(UIColor.systemFill))
                  .clipShape(RoundedRectangle(cornerRadius: 8))
              }

              Button {
                alert?.dismiss()
              } label: {
                Text("忽略")
                  .font(.system(size: 17, weight: .medium))
                  .frame(maxWidth: .infinity)
                  .frame(height: 40)
                  .background(Color(UIColor.systemRed))
                  .clipShape(RoundedRectangle(cornerRadius: 8))
              }
            }
            .foregroundStyle(Color.white)
            .padding(.top, 8)
          }
          .multilineTextAlignment(.center)
          .padding()
          .frame(width: 300)
          .background(.bar)
          .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        let alert = Alert(content: content)
        alert.show()
      } label: {
        Text("显示 SwiftUI View")
      }

      Button {
        let content = AlertHostingController { _ in
          HStack {
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
          }
        }
        let alert = ActionAlert(content: content)
        let cancel = Action(title: "取消", style: .cancel)
        let ignore = Action(title: "忽略", style: .destructive)
        alert.addAction(cancel)
        alert.addAction(ignore)
        alert.show()
      } label: {
        Text("显示带按钮的 SwiftUI View")
      }

      Button {
        showCustomAlert = true
      } label: {
        Text("通过 .easyAlert 修饰符显示 alert")
      }

      Button {
        showSelfAsAlert = true
      } label: {
        Text("把本页面作为 Alert 弹出")
      }
    }
  }
}

