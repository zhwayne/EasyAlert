//
//  ToastAlert.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

/// An alert implementation specifically designed for toast notifications.
///
/// `ToastAlert` extends the base `Alert` class to provide specialized functionality
/// for displaying toast messages. It includes a custom content view with support
/// for both text messages and loading indicators, along with appropriate styling
/// and layout management.
final class ToastAlert: Alert {

    /// A custom content view that displays the toast message and optional loading indicator.
    ///
    /// This view provides the visual representation of the toast, including a label
    /// for text content and an activity indicator for loading states. It features
    /// a blurred background with shadow effects for a modern appearance.
    class ContentView: UIView, AlertContent {

        /// The label that displays the toast message text.
        ///
        /// This label is configured for multi-line text display with appropriate
        /// content compression resistance to ensure proper layout behavior.
        let label = UILabel()
        
        /// The activity indicator that shows loading state.
        ///
        /// This indicator is used to show loading states and is hidden by default.
        /// It provides visual feedback for operations that require user waiting.
        let indicator = UIActivityIndicatorView(style: .medium)

        /// Creates a new content view with the specified frame.
        ///
        /// This initializer sets up the visual appearance of the toast, including
        /// shadow effects, blurred background, and proper layout constraints for
        /// the label and indicator.
        ///
        /// - Parameter frame: The frame rectangle for the view.
        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowOpacity = 0.1
            layer.shadowRadius = 5

            let effectView = BlurEffectView(frame: .zero)
            effectView.blurRadius = 50
            effectView.colorTint = UIColor.init(dynamicProvider: { tc in
                if tc.userInterfaceStyle == .dark {
                    return .systemGray
                } else {
                    return .black
                }
            })
            effectView.colorTintAlpha = 0.4
            effectView.clipsToBounds = true
            effectView.frame = bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            effectView.layer.cornerRadius = 13
            effectView.contentView.backgroundColor = UIColor(white: 0, alpha: 0.2)
            effectView.layer.cornerCurve = .continuous
            addSubview(effectView)

            label.numberOfLines = 0
            label.setContentCompressionResistancePriority(.required, for: .horizontal)

            indicator.isHidden = true
            indicator.setContentHuggingPriority(.required, for: .horizontal)

            let stackView = UIStackView(arrangedSubviews: [indicator, label])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.spacing = 8
            stackView.alignment = .center
            addSubview(stackView)

            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        }

        /// This initializer is not supported and will cause a fatal error.
        ///
        /// - Parameter coder: The NSCoder instance (unused).
        /// - Returns: This method always calls `fatalError`.
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    /// The raw custom view that contains the toast content.
    ///
    /// This property provides direct access to the content view for customization
    /// and content updates during the toast's lifecycle.
    var rawCustomView: ContentView { alertContent as! ContentView }

    /// Creates a new toast alert with the specified message.
    ///
    /// This initializer sets up the toast alert with the provided message content,
    /// configuring the appropriate animator, layout, and backdrop settings for
    /// optimal toast presentation.
    ///
    /// - Parameter message: The message content to display in the toast.
    public required init(message: Message) {
        let contentView = ContentView()
        super.init(content: contentView)
        contentView.label.attributedText = Toast.text(for: message)

        animator = ToastAnimator()
        layout = ToastLayout()
        backdrop.dimming = .color(.clear)
        backdrop.interactionScope = .all

        layoutGuide = LayoutGuide(
            width: .intrinsic,
            height: .intrinsic,
            contentInsets: UIEdgeInsets(top: 0, left: 36, bottom: 0, right: 36)
        )
    }

    /// Called before the toast is shown to configure the window level and start animations.
    ///
    /// This method ensures the toast appears above all other content by setting
    /// the window level to the highest possible value, and starts the activity
    /// indicator animation if it's visible.
    override func willShow() {
        super.willShow()
        if let window = rawCustomView.window {
            window.windowLevel = UIWindow.Level(.greatestFiniteMagnitude)
        }
        if !rawCustomView.indicator.isHidden {
            rawCustomView.indicator.startAnimating()
        }
    }

    /// Called after the toast is dismissed to stop animations and clean up.
    ///
    /// This method stops the activity indicator animation and performs any
    /// necessary cleanup when the toast is dismissed.
    override func didDismiss() {
        super.didDismiss()
        rawCustomView.indicator.stopAnimating()
    }
}

/// An extension that provides text conversion methods for toast messages.
///
/// This extension handles the conversion of various message types to attributed strings
/// for display in toast notifications, supporting both plain text and rich text formats.
extension Toast {

    /// Converts a message to an attributed string for display.
    ///
    /// This method handles the conversion of various message types to attributed strings,
    /// applying the appropriate formatting for toast display.
    ///
    /// - Parameter message: The message to convert to an attributed string.
    /// - Returns: An attributed string representation of the message, or `nil` if the message is `nil`.
    static func text(for message: Message?) -> NSAttributedString? {
        if let text = message as? String {
            return attributedMessage(text)
        }
        if #available(iOS 15, *), let text = message as? AttributedString {
            return NSAttributedString(text)
        }
        return message as? NSAttributedString
    }
}

/// An extension that provides attributed string creation methods for toast messages.
///
/// This extension handles the creation of attributed strings with proper formatting
/// for toast messages, including typography and styling options.
extension Toast {

    /// The attributed string attributes for toast message text.
    ///
    /// This computed property returns the attributes dictionary that should be applied
    /// to toast message text, including font, color, alignment, and paragraph styling.
    static private var messageAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byCharWrapping
        attributes[.font] = UIFont.systemFont(ofSize: 15)
        attributes[.foregroundColor] = UIColor.white
        attributes[.paragraphStyle] = paragraphStyle.copy()
        return attributes
    }

    /// Creates an attributed string for the specified message text.
    ///
    /// This method applies the toast message attributes to the provided text,
    /// creating a properly formatted attributed string for display.
    ///
    /// - Parameter message: The message text to format.
    /// - Returns: An attributed string with the toast message attributes applied.
    static func attributedMessage(_ message: String) -> NSAttributedString {
        let range = NSMakeRange(0, message.count)
        let attributedMessage = NSMutableAttributedString(string: message)
        attributedMessage.addAttributes(messageAttributes, range: range)
        return NSAttributedString(attributedString: attributedMessage)
    }
}
