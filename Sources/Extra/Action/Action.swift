//
//  Action.swift
//  EasyAlert
//
//  Created by iya on 2021/7/27.
//

import UIKit

/// A closure that handles action execution.
///
/// This closure is called when the user taps on an action button.
/// - Parameter action: The action that was triggered.
public typealias ActionHandler = (Action) -> Void

/// A user action that can be added to alerts, action sheets, and other UI components.
///
/// An `Action` represents a user-interactable element that can be displayed in various alert contexts.
/// It encapsulates the action's title, style, and behavior when triggered.
@MainActor public final class Action {

    /// A Boolean value that determines whether the alert automatically dismisses when this action is triggered.
    ///
    /// When `true`, tapping this action will immediately dismiss the alert.
    /// When `false`, the developer must manually dismiss the alert.
    public var autoDismissesOnAction: Bool = true

    /// The visual style of the action.
    ///
    /// The style determines the appearance and behavior of the action button.
    public let style: Style

    /// The title text displayed on the action button.
    ///
    /// This text appears as the button's label to the user.
    public let title: String?

    /// The closure to execute when the action is triggered.
    ///
    /// This handler is called when the user taps the action button.
    let handler: ActionHandler?

    /// The view that represents this action in the user interface.
    ///
    /// This view is responsible for rendering the action button.
    var view: (UIView & ActionContent)?

    /// The representation view that contains this action's view.
    ///
    /// This is used for managing the action's visual representation.
    weak var representationView: ActionCustomViewRepresentationView?

    /// Creates an action with the specified title, style, and handler.
    ///
    /// - Parameters:
    ///   - title: The text to display on the action button.
    ///   - style: The visual style of the action.
    ///   - handler: An optional closure to execute when the action is triggered.
    public init(title: String, style: Style, handler: ActionHandler? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    /// Creates an action with a custom view and handler.
    ///
    /// - Parameters:
    ///   - view: A custom view that conforms to `ActionContent` protocol.
    ///   - handler: An optional closure to execute when the action is triggered.
    public init(view: UIView & ActionContent, handler: ActionHandler? = nil) {
        self.view = view
        self.title = view.title
        self.style = view.style
        self.handler = handler
    }

    deinit {
        MainActor.assumeIsolated {
            view?.removeFromSuperview()
        }
    }

    /// A Boolean value that determines whether the action is enabled.
    ///
    /// When `false`, the action button becomes non-interactive and typically appears dimmed.
    /// When `true`, the action button is interactive and responds to user interaction.
    public var isEnabled: Bool = true {
        didSet {
            guard let representationView = view?.superview as? ActionCustomViewRepresentationView else {
                return
            }
            representationView.isEnabled = isEnabled
        }
    }
}

public extension Action {

    /// The visual style of an action.
    ///
    /// The style determines the appearance and behavior of the action button.
    enum Style: Hashable {
        /// The default style for most actions.
        ///
        /// This style typically appears as a standard button with normal text color.
        case `default`
        
        /// The cancel style for cancel actions.
        ///
        /// This style is typically used for actions that cancel the current operation.
        case cancel
        
        /// The destructive style for potentially harmful actions.
        ///
        /// This style typically appears with red text to indicate a destructive action.
        case destructive
    }
}
