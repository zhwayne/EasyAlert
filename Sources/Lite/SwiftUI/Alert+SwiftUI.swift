//
//  Alert+SwiftUI.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import Foundation
import SwiftUI

@MainActor
private struct DismissibleEnvironmentKey: @preconcurrency EnvironmentKey {
    static var defaultValue: Dismissible?
}

extension EnvironmentValues {
    public var alert: Dismissible? {
        get { self[DismissibleEnvironmentKey.self] }
        set { self[DismissibleEnvironmentKey.self] = newValue }
    }
}

@MainActor final public class AlertHostingController: UIHostingController<AnyView>, AlertContent {

    private class WeakRef: Dismissible {

        private weak var object: Dismissible?

        init(_ object: Dismissible) {
            self.object = object
        }

        func dismiss() async {
            await object?.dismiss()
        }

        func dismiss(completion: (() -> Void)?) {
            object?.dismiss(completion: completion)
        }
    }

    private var weakObject: WeakRef!

    public required init<Content: View>(@ViewBuilder viewBuilder: (Dismissible?) -> Content) {
        super.init(rootView: AnyView(EmptyView()))
        if #available(iOS 16.0, *) {
            sizingOptions = [.intrinsicContentSize]
        } else {
            // Fallback on earlier versions
        }
        weakObject = WeakRef(self)
        rootView = AnyView(erasing: viewBuilder(weakObject).environment(\.alert, weakObject))
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

@MainActor
private struct AlertController<Content: View>: UIViewControllerRepresentable {

    @Binding var isPresented: Bool
    @State var alreadyPresented = false
    var allowDismissWhenBackgroundTouch: Bool
    var content: (Dismissible?) -> Content

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
            if !isPresented {
                context.coordinator.alert = nil
                alert.dismiss {
                    alreadyPresented = false
                }
            }
        } else {
            if isPresented {
                let alert = Alert(content: AlertHostingController { alert in
                    content(alert)
                })
                alert.backdrop.allowDismissWhenBackgroundTouch = allowDismissWhenBackgroundTouch
                alert.addListener(LifecycleCallback(willShow: {
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

extension View {

    public func easyAlert<Content: View>(
        isPresented: Binding<Bool>,
        allowDismissWhenBackgroundTouch: Bool = false,
        @ViewBuilder content: @escaping
        (Dismissible?) -> Content
    ) -> some View {
        self.background(
            AlertController(
                isPresented: isPresented,
                allowDismissWhenBackgroundTouch: allowDismissWhenBackgroundTouch,
                content: content
            )
        )
    }
}
