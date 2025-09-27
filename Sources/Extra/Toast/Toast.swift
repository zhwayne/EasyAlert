//
//  Toast.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

/// A toast notification that displays temporary messages to the user.
///
/// `Toast` provides a simple way to show brief messages that automatically disappear.
/// It's commonly used for showing status updates, confirmations, or error messages.
/// The toast system supports both automatic dismissal based on message length and
/// manual dismissal with customizable positioning and interaction scopes.
@MainActor public struct Toast {

    /// The currently displayed toast alert, if any.
    ///
    /// This static property holds the active toast alert instance, ensuring only
    /// one toast can be displayed at a time. When a new toast is shown, it
    /// replaces any existing toast.
    private static var alert: ToastAlert?

    /// The work item responsible for automatically dismissing the toast.
    ///
    /// This property manages the automatic dismissal timer, allowing the toast
    /// to be dismissed after a specified duration. It can be cancelled if a
    /// new toast is shown before the current one expires.
    private static var dismissWork: DispatchWorkItem?

    /// Schedules the toast to be dismissed after the specified duration.
    ///
    /// This method sets up an automatic dismissal timer for the toast, ensuring
    /// it disappears after the specified time interval. The dismissal is performed
    /// asynchronously with high priority to maintain smooth user experience.
    ///
    /// - Parameter duration: The time interval after which the toast should be dismissed.
    private static func dismissAfter(duration: TimeInterval) {
        dismissWork = DispatchWorkItem(qos: .userInteractive, block: {
            Self.alert?.dismiss()
            Self.alert = nil
            Self.dismissWork = nil
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: dismissWork!)
    }
}

/// An extension that provides duration calculation for toast messages.
///
/// This extension includes methods for calculating appropriate display durations
/// based on message content, ensuring users have sufficient time to read the message.
extension Toast {

    /// Calculates the appropriate display duration for the given text.
    ///
    /// The duration is calculated based on the text length to ensure users have enough time to read the message.
    /// Short messages (5 characters or less) have a fixed duration, while longer messages
    /// get additional time proportional to their length.
    ///
    /// - Parameter text: The text to calculate duration for.
    /// - Returns: The calculated duration in seconds.
    private static func duration(of text: String) -> TimeInterval {
        // Text with 5 characters or less has a fixed duration of 1.5 seconds
        let threshold = 5
        let minimumDuratuon: TimeInterval = 1.5

        if text.count <= threshold { return minimumDuratuon }
        let leftTextLen = text.count - threshold
        let extDuration = Double(leftTextLen) * 0.14
        return minimumDuratuon + extDuration
    }
}

/// An extension that defines positioning options for toast notifications.
///
/// This extension provides the positioning enum that determines where the toast
/// appears on the screen, offering flexibility in visual presentation.
extension Toast {

    /// The position where the toast is displayed on the screen.
    ///
    /// This enum defines the available positioning options for toast notifications,
    /// allowing developers to choose the most appropriate location for their use case.
    public enum Position {
        /// The toast appears in the center of the screen.
        ///
        /// This position is ideal for important messages that require immediate attention,
        /// as it places the toast in the most prominent location on the screen.
        case center
        
        /// The toast appears at the bottom of the screen.
        ///
        /// This position is ideal for status updates and confirmations, as it
        /// doesn't interfere with the main content area and follows common UI patterns.
        case bottom
    }
}

/// An extension that provides the main interface for displaying toast notifications.
///
/// This extension includes the primary methods for showing and dismissing toast
/// notifications, with comprehensive configuration options for positioning,
/// duration, and user interaction.
extension Toast {

    /// Shows a toast message with the specified parameters.
    ///
    /// This method displays a toast notification with the provided message and configuration.
    /// If a toast is already displayed, it will be replaced with the new one. The method
    /// supports automatic duration calculation based on message length and provides
    /// flexible positioning and interaction options.
    ///
    /// - Parameters:
    ///   - message: The message to display in the toast.
    ///   - duration: The duration to display the toast. If `nil`, the duration is calculated based on the message length.
    ///   - position: The position where the toast should appear on the screen.
    ///   - interactionScope: The scope of user interaction allowed while the toast is displayed.
    public static func show(
        _ message: Message,
        duration: TimeInterval? = nil,
        position: Position = .bottom,
        interactionScope: BackdropInteractionScope = .all
    ) {
        guard let string = Toast.text(for: message)?.string else { return }

        if dismissWork != nil {
            dismissWork?.cancel()
            dismissWork = nil
        }

        if let alert = alert {
            alert.rawCustomView.label.attributedText = Toast.text(for: message)
        } else {
            alert = ToastAlert(message: message)
        }

        if let layoutModifier = alert?.layout as? ToastLayout {
            layoutModifier.position = position
        }

        let parameters = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: 1.0, timingParameters: parameters)
        animator.addAnimations {
            alert?.rawCustomView.indicator.isHidden = duration != .infinity
            alert?.rawCustomView.indicator.alpha = duration == .infinity ? 1 : 0
        }
        animator.startAnimation()

        alert?.backdrop.interactionScope = interactionScope
        if !alert!.isActive {
            alert?.show()
        } else {
            let timing = UISpringTimingParameters()
            let animator = UIViewPropertyAnimator(duration: 1/* This value will be ignored.*/, timingParameters: timing)
            animator.addAnimations {
                alert!.updateLayout()
            }
            animator.startAnimation()
        }

        if let duration, duration >= 0.5 {
            dismissAfter(duration: duration)
        } else {
            dismissAfter(duration: Toast.duration(of: string))
        }
    }

    /// Dismisses the currently displayed toast asynchronously.
    ///
    /// This method provides an async interface for dismissing the toast, allowing
    /// for proper handling of the dismissal animation and cleanup.
    ///
    /// - Returns: An async operation that completes when the toast is fully dismissed.
    public static func dismiss() async {
        if let alert = alert {
            await alert.dismiss()
        }
    }

    /// Dismisses the currently displayed toast with an optional completion handler.
    ///
    /// This method provides a synchronous interface for dismissing the toast with
    /// an optional completion handler that is called when the dismissal animation finishes.
    ///
    /// - Parameter completion: An optional closure to execute when the dismissal animation completes.
    public static func dismiss(completion: (() -> Void)? = nil) {
        if let alert = alert {
            alert.dismiss(completion: completion)
        } else {
            completion?()
        }
    }
}
