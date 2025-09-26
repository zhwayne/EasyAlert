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
@MainActor public struct Toast {

    /// The currently displayed toast alert, if any.
    private static var alert: ToastAlert?

    /// The work item responsible for automatically dismissing the toast.
    private static var dismissWork: DispatchWorkItem?

    /// Schedules the toast to be dismissed after the specified duration.
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

extension Toast {

    /// Calculates the appropriate display duration for the given text.
    ///
    /// The duration is calculated based on the text length to ensure users have enough time to read the message.
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

extension Toast {

    /// The position where the toast is displayed on the screen.
    public enum Position {
        /// The toast appears in the center of the screen.
        case center
        
        /// The toast appears at the bottom of the screen.
        case bottom
    }
}

extension Toast {

    /// Shows a toast message with the specified parameters.
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
    /// - Returns: An async operation that completes when the toast is fully dismissed.
    public static func dismiss() async {
        if let alert = alert {
            await alert.dismiss()
        }
    }

    /// Dismisses the currently displayed toast with an optional completion handler.
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
