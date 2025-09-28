//
//  ToastSectionView.swift
//

import SwiftUI
import EasyAlert

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

