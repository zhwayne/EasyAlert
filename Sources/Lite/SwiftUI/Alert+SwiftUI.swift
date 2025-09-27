//
//  Alert+SwiftUI.swift
//  EasyAlert
//
//  Created by W on 2025/2/11.
//

import Foundation
import SwiftUI

/// An environment key that provides access to the dismissible alert instance in SwiftUI views.
///
/// This environment key allows SwiftUI views to access the alert's dismissible interface,
/// enabling them to dismiss the alert programmatically. The key uses `@preconcurrency`
/// to maintain compatibility with Swift 5.5 and earlier versions.
@MainActor
private struct DismissibleEnvironmentKey: @preconcurrency EnvironmentKey {
    /// The default value for the dismissible environment key.
    ///
    /// Returns `nil` by default, indicating no alert is available in the environment.
    static var defaultValue: Dismissible?
}

/// An extension that adds alert support to SwiftUI's environment values.
///
/// This extension provides a convenient way to access and set the dismissible alert
/// instance in SwiftUI views through the environment system.
extension EnvironmentValues {
    /// The dismissible alert instance available in the current environment.
    ///
    /// This property allows SwiftUI views to access the alert's dismissible interface,
    /// enabling them to dismiss the alert programmatically. Views can use this
    /// environment value to implement custom dismissal logic.
    public var alert: Dismissible? {
        get { self[DismissibleEnvironmentKey.self] }
        set { self[DismissibleEnvironmentKey.self] = newValue }
    }
}

/// A hosting controller that bridges SwiftUI views with the alert system.
///
/// `AlertHostingController` is a specialized `UIHostingController` that serves as a bridge
/// between SwiftUI views and the alert system. It conforms to `AlertContent` to enable
/// dismissal functionality and provides a weak reference mechanism to prevent retain cycles.
@MainActor final public class AlertHostingController: UIHostingController<AnyView>, AlertContent {

    /// A weak reference wrapper that prevents retain cycles while maintaining dismissible functionality.
    ///
    /// `WeakRef` provides a safe way to hold a weak reference to a dismissible object
    /// while still allowing it to be dismissed. This prevents retain cycles that could
    /// occur when the alert holds a strong reference to itself.
    private class WeakRef: Dismissible {

        /// A weak reference to the dismissible object.
        private weak var object: Dismissible?

        /// Creates a new weak reference wrapper for the specified dismissible object.
        ///
        /// - Parameter object: The dismissible object to wrap with a weak reference.
        init(_ object: Dismissible) {
            self.object = object
        }

        /// Dismisses the wrapped object asynchronously.
        ///
        /// This method forwards the dismissal call to the wrapped object if it still exists.
        func dismiss() async {
            await object?.dismiss()
        }

        /// Dismisses the wrapped object with a completion handler.
        ///
        /// - Parameter completion: A closure to execute when the dismissal completes.
        func dismiss(completion: (() -> Void)?) {
            object?.dismiss(completion: completion)
        }
    }

    /// A weak reference to this controller to prevent retain cycles.
    private var weakObject: WeakRef!

    /// Creates a new alert hosting controller with the specified SwiftUI content.
    ///
    /// This initializer creates a hosting controller that can display SwiftUI content
    /// within an alert. The content builder receives a dismissible reference that
    /// can be used to dismiss the alert programmatically.
    ///
    /// - Parameter viewBuilder: A closure that builds the SwiftUI content for the alert.
    ///   The closure receives a dismissible reference that can be used to dismiss the alert.
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

    /// This initializer is not supported and will cause a fatal error.
    ///
    /// - Parameter coder: The NSCoder instance (unused).
    /// - Returns: This method always calls `fatalError`.
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configures the view controller after the view has loaded.
    ///
    /// This method sets the background color to clear to ensure the alert content
    /// is properly displayed without any background interference.
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

/// A SwiftUI view controller representable that manages alert presentation.
///
/// `AlertController` is a private struct that implements `UIViewControllerRepresentable`
/// to bridge SwiftUI's declarative interface with UIKit's alert system. It manages
/// the presentation and dismissal of alerts based on the `isPresented` binding.
@MainActor
private struct AlertController<Content: View>: UIViewControllerRepresentable {

    /// A binding that controls whether the alert is currently presented.
    @Binding var isPresented: Bool
    
    /// A state variable that tracks whether the alert has already been presented.
    @State var alreadyPresented = false
    
    /// A flag that determines whether the alert can be dismissed by tapping the background.
    var allowDismissWhenBackgroundTouch: Bool
    
    /// A closure that builds the SwiftUI content for the alert.
    var content: (Dismissible?) -> Content

    /// The type of view controller that this representable creates.
    typealias UIViewControllerType = UIViewController

    /// Creates the underlying view controller for the alert.
    ///
    /// This method creates a new view controller with a clear background and
    /// immediately updates it with the current context to ensure proper initialization.
    ///
    /// - Parameter context: The context for the view controller creation.
    /// - Returns: A new view controller configured for alert presentation.
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        updateUIViewController(viewController, context: context)
        return viewController
    }

    /// Creates a coordinator to manage the alert lifecycle.
    ///
    /// The coordinator maintains a reference to the alert instance and handles
    /// the presentation and dismissal logic.
    ///
    /// - Returns: A new coordinator instance.
    func makeCoordinator() -> Coordinate {
        let coordinator = Coordinate(parent: self)
        return coordinator
    }

    /// Updates the view controller when the SwiftUI state changes.
    ///
    /// This method handles the presentation and dismissal of alerts based on the
    /// `isPresented` binding. It manages the alert lifecycle and ensures proper
    /// state synchronization between SwiftUI and the alert system.
    ///
    /// - Parameters:
    ///   - uiViewController: The view controller to update.
    ///   - context: The context containing the coordinator and other state information.
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

    /// A coordinator class that manages the alert lifecycle and state.
    ///
    /// The `Coordinate` class serves as a bridge between SwiftUI and the alert system,
    /// maintaining references to the alert instance and handling state transitions.
    @MainActor class Coordinate {

        /// The parent alert controller that owns this coordinator.
        let parent: AlertController
        
        /// The current alert instance being managed.
        var alert: Alert?

        /// Creates a new coordinator for the specified alert controller.
        ///
        /// - Parameter parent: The alert controller that owns this coordinator.
        init(parent: AlertController) {
            self.parent = parent
        }
    }
}

/// An extension that adds easy alert functionality to SwiftUI views.
///
/// This extension provides a convenient way to present alerts in SwiftUI views
/// using a declarative approach that integrates seamlessly with SwiftUI's state management.
extension View {

    /// Presents an alert with the specified content when the binding becomes true.
    ///
    /// This method creates an alert that is presented when `isPresented` is true
    /// and dismissed when it becomes false. The alert content is built using the
    /// provided view builder closure, which receives a dismissible reference for
    /// programmatic dismissal.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the alert is presented.
    ///   - allowDismissWhenBackgroundTouch: A flag that determines whether the alert
    ///     can be dismissed by tapping the background. Defaults to `false`.
    ///   - content: A view builder closure that creates the alert content.
    ///     The closure receives a dismissible reference that can be used to dismiss the alert.
    /// - Returns: A view with the alert functionality attached.
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
