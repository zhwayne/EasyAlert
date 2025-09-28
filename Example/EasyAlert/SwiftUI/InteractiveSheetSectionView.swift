//
//  InteractiveSheetSectionView.swift
//

import SwiftUI
import EasyAlert
import UIKit

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
            .padding(.bottom, 40)
          }
          .padding(.top, 20)
          .background(.regularMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
          .ignoresSafeArea()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        let sheet = Sheet(content: content)
        sheet.isInteractive = true
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
          .background(.regularMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
          .ignoresSafeArea()
          .frame(maxWidth: .infinity, maxHeight: 500)
        }
        let sheet = Sheet(content: content)
        sheet.isInteractive = true
        sheet.backdrop.allowDismissWhenBackgroundTouch = true
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
            .padding(.bottom, 40)
          }
          .padding(.top, 20)
          .background(.regularMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
          .ignoresSafeArea()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        let sheet = Sheet(content: content)
        sheet.isInteractive = true
        sheet.show()
      } label: {
        Text("自定义样式交互式弹窗")
      }
    }
  }
}

