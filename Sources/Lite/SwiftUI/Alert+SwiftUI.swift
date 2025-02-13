//
//  File.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
final class AlertContentHostingController<Content: View>: UIHostingController<Content>, AlertCustomizable {

    override init(rootView: Content) {
        super.init(rootView: rootView)
        
    }
}



//@available(iOS 13.0, *)
//extension View {
//    
//    public func easyAlert<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
//        
//    }
//}
