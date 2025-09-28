//
//  ContentView.swift
//  EasyAlert_Example
//
//  Created by W on 2025/2/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI
import EasyAlert

private var alertTitle: String {
  "要移除无线局域网“Meizu-0D23-5G”吗？"
}

private var message: String {
  "您的设备和其他使用iCloud钥匙串的设备将不再加入此无线局域网络。"
}

struct ContentView: View {
  
  @Environment(\.alert) private var alert
  @State private var showCustomAlert = false
  @State private var showSelfAsAlert = false
  
  var body: some View {
    List {
      if let alert {
        Section {
          Button {
            alert.dismiss()
          } label: {
            Text("关闭弹出页面")
          }
        }
      }
      
      MessageAlertSectionView()
      
      CustomAlertSectionView()
      
      SwiftUIAlertSectionView(
        showCustomAlert: $showCustomAlert,
        showSelfAsAlert: $showSelfAsAlert
      )
      
      BottomSheetSectionView()
      
      InteractiveSheetSectionView()
      
      ToastSectionView()
    }
    .easyAlert(isPresented: $showCustomAlert) { alert in
      VStack(spacing: 16) {
        Text("SwiftUI Alert")
        
        Button {
          alert?.dismiss()
        } label: {
          Text("取消")
            .font(.system(size: 17, weight: .medium))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(UIColor.systemFill))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .contentShape(Rectangle())
        }
      }
      .padding()
      .frame(width: 300)
      .background(.bar)
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .easyAlert(isPresented: $showSelfAsAlert) { _ in
      ContentView()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(8)
        .frame(width: 300, height: 480)
        .background(.bar)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
  }
}

var rootViewController: UIViewController {
  UIApplication.shared.delegate!.window!!.rootViewController!
}

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
          try? await Task.sleep(nanoseconds:2_000_000_000)
          await alert.dismiss()
          print("Alert destroyed.")
        }
      } label: {
        Text("3个按钮, 2秒后自动消失")
      }
    }
  }
}

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

struct InteractiveSheetSectionView: View {
  var body: some View {
    Section("交互式底部弹窗") {
      Button {
        let content = AlertHostingController { alert in
          VStack(spacing: 16) {
            
            Text("拖拽交互式弹窗")
              .font(.system(size: 20, weight: .semibold))
            
            Text("您可以拖拽此弹窗向下滑动来关闭它")
              .font(.system(size: 16))
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
              Text("功能特点：")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
              
              FeatureRow(icon: "hand.draw.fill", title: "拖拽关闭", description: "向下拖拽即可关闭弹窗")
              FeatureRow(icon: "arrow.down.circle.fill", title: "实时反馈", description: "拖拽过程中实时显示动画效果")
              FeatureRow(icon: "touchid", title: "智能识别", description: "自动忽略按钮区域的拖拽手势")
              FeatureRow(icon: "arrow.uturn.backward", title: "弹性回弹", description: "未达到阈值时自动回弹")
            }
            .padding(.horizontal)
            
            Spacer(minLength: 20)
            
            HStack(spacing: 12) {
              Button {
                alert?.dismiss()
              } label: {
                Text("取消")
                  .font(.system(size: 17, weight: .medium))
                  .frame(maxWidth: .infinity)
                  .frame(height: 44)
                  .background(Color(UIColor.systemFill))
                  .clipShape(RoundedRectangle(cornerRadius: 12))
                  .foregroundColor(.primary)
              }
              
              Button {
                alert?.dismiss()
              } label: {
                Text("确定")
                  .font(.system(size: 17, weight: .medium))
                  .frame(maxWidth: .infinity)
                  .frame(height: 44)
                  .background(Color.accentColor)
                  .clipShape(RoundedRectangle(cornerRadius: 12))
                  .foregroundColor(.white)
              }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
          }
          .padding(.top, 20)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.regularMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        let sheet = InteractiveSheet(content: content)
        sheet.show()
      } label: {
        Text("基础交互式弹窗")
      }
      
      Button {
        let content = AlertHostingController { alert in
          ScrollView {
            VStack(spacing: 20) {
              
              Text("可滚动交互式弹窗")
                .font(.system(size: 22, weight: .bold))
              
              Text("这个弹窗包含可滚动内容，拖拽手势会智能地与滚动视图协作")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
              
              // Simulate long content - reduced to 10 items for better height
              ForEach(1...10, id: \.self) { index in
                HStack {
                  Circle()
                    .fill(Color.accentColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                      Text("\(index)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    )
                  
                  VStack(alignment: .leading, spacing: 4) {
                    Text("列表项 \(index)")
                      .font(.system(size: 17, weight: .medium))
                    Text("这是第 \(index) 个列表项的内容描述")
                      .font(.system(size: 14))
                      .foregroundColor(.secondary)
                  }
                  
                  Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
              }
              
              Spacer(minLength: 20)
            }
            .padding(.top, 20)
          }
          .frame(maxWidth: .infinity, maxHeight: 500) // 限制最大高度为 500
          .background(.regularMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        let sheet = InteractiveSheet(content: content)
        sheet.show()
      } label: {
        Text("可滚动内容交互式弹窗")
      }
      
      Button {
        let content = AlertHostingController { alert in
            VStack(spacing: 16) {
            
            Text("自定义样式交互式弹窗")
              .font(.system(size: 20, weight: .semibold))
            
            Text("展示自定义配置的交互式弹窗")
              .font(.system(size: 16))
              .foregroundColor(.secondary)
            
            // Custom styled content
            VStack(spacing: 16) {
              HStack {
                Image(systemName: "star.fill")
                  .foregroundColor(.yellow)
                  .font(.title2)
                Text("评分")
                  .font(.system(size: 18, weight: .medium))
                Spacer()
                Text("5.0")
                  .font(.system(size: 18, weight: .bold))
                  .foregroundColor(.accentColor)
              }
              .padding()
              .background(Color(UIColor.secondarySystemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 12))
              
              HStack {
                Image(systemName: "heart.fill")
                  .foregroundColor(.red)
                  .font(.title2)
                Text("收藏")
                  .font(.system(size: 18, weight: .medium))
                Spacer()
                Text("1,234")
                  .font(.system(size: 18, weight: .bold))
                  .foregroundColor(.accentColor)
              }
              .padding()
              .background(Color(UIColor.secondarySystemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 12))
              
              HStack {
                Image(systemName: "square.and.arrow.up")
                  .foregroundColor(.blue)
                  .font(.title2)
                Text("分享")
                  .font(.system(size: 18, weight: .medium))
                Spacer()
                Text("分享到")
                  .font(.system(size: 16))
                  .foregroundColor(.secondary)
              }
              .padding()
              .background(Color(UIColor.secondarySystemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button {
              alert?.dismiss()
            } label: {
              Text("完成")
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
          }
          .padding(.top, 20)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.regularMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        let sheet = InteractiveSheet(content: content)
        sheet.show()
      } label: {
        Text("自定义样式交互式弹窗")
      }
    }
  }
}

struct FeatureRow: View {
  let icon: String
  let title: String
  let description: String
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .foregroundColor(.accentColor)
        .font(.title3)
        .frame(width: 24)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(size: 16, weight: .medium))
        Text(description)
          .font(.system(size: 14))
          .foregroundColor(.secondary)
      }
      
      Spacer()
    }
    .padding(.horizontal, 20)
  }
}

struct ToastSectionView: View {
  var body: some View {
    Section("Toast") {
      Button {
        Toast.show(message)
      } label: {
        Text("显示 Toast")
      }
    }
  }
}

#Preview {
  ContentView()
}
