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

      Button {
        // 使用 SwiftUI 自定义 View + Slider 动态修改 sheet 的 layoutGuide.height
        var applyHeight: ((CGFloat) -> Void)?

        let content = AlertHostingController { _ in
          DynamicHeightContentView(initialHeight: 320) { newHeight in
            applyHeight?(newHeight)
          }
          .background(.regularMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
          .ignoresSafeArea()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        let sheet = Sheet(content: content)
        applyHeight = { [weak sheet] newHeight in
          sheet?.layoutGuide.height = .fixed(newHeight)
        }
        sheet.backdrop.allowDismissWhenBackgroundTouch = true
        sheet.show()
      } label: {
        Text("SwiftUI 自定义视图(动态高度)")
      }
    }
  }
}

private struct DynamicHeightContentView: View {
  @Environment(\.alert) private var alert

  @State private var height: Double
  var onHeightChange: (CGFloat) -> Void

  init(initialHeight: CGFloat, onHeightChange: @escaping (CGFloat) -> Void) {
    self._height = State(initialValue: Double(initialHeight))
    self.onHeightChange = onHeightChange
  }

  var body: some View {
    VStack(spacing: 16) {
      Text("动态修改 Sheet 高度")
        .font(.system(size: 20, weight: .semibold))

      Text("通过下方滑块实时调整 layoutGuide.height")
        .font(.system(size: 15))
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)

      VStack(spacing: 12) {
        HStack {
          Text("高度: ")
            .font(.system(size: 16))
            .foregroundColor(.secondary)
          Text("\(Int(height)) pt")
            .font(.system(size: 18, weight: .medium))
          Spacer()
        }

        Slider(value: $height, in: 240...600, step: 1)
          .onChange(of: height) { newValue in
            onHeightChange(CGFloat(newValue))
          }
      }
      .padding(.horizontal)

      Spacer(minLength: 12)

      HStack(spacing: 12) {
        Button {
          let target = max(240, min(600, height - 40))
          height = target
          onHeightChange(CGFloat(target))
        } label: {
          Text("-40")
            .font(.system(size: 16, weight: .medium))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(UIColor.systemFill))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .foregroundColor(.primary)
        }

        Button {
          let target = max(240, min(600, height + 40))
          height = target
          onHeightChange(CGFloat(target))
        } label: {
          Text("+40")
            .font(.system(size: 16, weight: .medium))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(UIColor.systemFill))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .foregroundColor(.primary)
        }
      }
      .padding(.horizontal)

      Button {
        alert?.dismiss()
      } label: {
        Text("关闭")
          .font(.system(size: 17, weight: .semibold))
          .frame(maxWidth: .infinity)
          .frame(height: 48)
          .background(Color.accentColor)
          .clipShape(RoundedRectangle(cornerRadius: 14))
          .foregroundColor(.white)
      }
      .padding(.horizontal)
      .padding(.bottom, 40)
    }
    .padding(.top, 20)
    .onAppear {
      onHeightChange(CGFloat(height))
    }
  }
}
