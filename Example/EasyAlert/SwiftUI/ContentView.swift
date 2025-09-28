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

// Moved section views to separate files under the same folder.

#Preview {
  ContentView()
}
