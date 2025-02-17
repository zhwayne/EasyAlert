//
//  Alert+SwiftUI.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
@MainActor final public class AlertHostingController<Content: View>: UIHostingController<Content>, AlertCustomizable {
    
    public convenience init(@ViewBuilder viewBuilder: () -> Content) {
        self.init(rootView: viewBuilder())
        if #available(iOS 16.0, *) {
            sizingOptions = [.intrinsicContentSize]
        } else {
            // Fallback on earlier versions
        }
    }
    
    public override init(rootView: Content) {
        super.init(rootView: rootView)
        if #available(iOS 16.0, *) {
            sizingOptions = [.intrinsicContentSize]
        } else {
            // Fallback on earlier versions
        }
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            self.view.setNeedsUpdateConstraints()
        }
    }
}

@available(iOS 13.0, *)
@MainActor
private struct AlertController<Content: View>: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    @State var alreadyPresented = false
    var allowDismissWhenBackgroundTouch: Bool
    var content: Content
    
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        updateUIViewController(viewController, context: context)
        return viewController
    }
    
    func makeCoordinator() -> Coordinate {
        let coordinator = Coordinate(parent: self)
        return coordinator
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if alreadyPresented, let alert = context.coordinator.alert {
            if let hostingController = alert.alertContent as? AlertHostingController<Content> {
                hostingController.rootView = content
            }
            if !isPresented {
                context.coordinator.alert = nil
                alert.dismiss {
                    alreadyPresented = false
                }
            }
        } else {
            if isPresented {
                let alert = Alert(content: AlertHostingController(rootView: content))
                alert.backdropProvider.allowDismissWhenBackgroundTouch = allowDismissWhenBackgroundTouch
                alert.addListener(LiftcycleCallback(willShow: {
                    alreadyPresented = true
                }, willDismiss: {
                    isPresented = false
                }))
                context.coordinator.alert = alert
                DispatchQueue.main.async {
                    alert.show()
                }
            }
        }
    }
    
    @MainActor class Coordinate {
        
        let parent: AlertController
        var alert: Alert?
        
        init(parent: AlertController) {
            self.parent = parent
        }
    }
}

@available(iOS 13.0, *)
extension View {
    
    public func easyAlert<Content: View>(
        isPresented: Binding<Bool>,
        allowDismissWhenBackgroundTouch: Bool = false,
        @ViewBuilder content: @escaping
        () -> Content
    ) -> some View {
        self.background(
            AlertController(
                isPresented: isPresented,
                allowDismissWhenBackgroundTouch: allowDismissWhenBackgroundTouch,
                content: content()
            )
        )
    }
}
