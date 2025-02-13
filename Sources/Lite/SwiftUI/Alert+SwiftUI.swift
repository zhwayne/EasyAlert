//
//  Alert+SwiftUI.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
final public class EasyAlertHostingController<Content: View>: UIHostingController<Content>, AlertCustomizable {

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        if #available(iOS 16.0, *) {
            sizingOptions = [.preferredContentSize]
        } else {
            // Fallback on earlier versions
        }
        DispatchQueue.main.async {
            self.view.setNeedsUpdateConstraints()
        }
    }
}

@available(iOS 13.0, *)
extension Alert {
    
    public convenience init<Content: View>(@ViewBuilder swiftUIContent: () -> Content) {
        let hostingController = EasyAlertHostingController(rootView: swiftUIContent())
        self.init(content: hostingController)
    }
}

//@available(iOS 13.0, *)
//extension View {
//    
//    public func easyAlert<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
//        
//    }
//}
