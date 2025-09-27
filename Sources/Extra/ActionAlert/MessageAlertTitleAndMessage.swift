//
//  MessageAlertTitleAndMessage.swift
//  EasyAlert
//
//  Created by iya on 2022/5/13.
//

import UIKit

/// An extension that provides text conversion methods for message alerts.
///
/// This extension handles the conversion of various text types to attributed strings
/// for display in message alerts, supporting both plain text and rich text formats.
extension MessageAlert {

    /// Converts a title to an attributed string for display.
    ///
    /// This method handles the conversion of various title types to attributed strings,
    /// applying the appropriate formatting based on the title configuration.
    ///
    /// - Parameter title: The title to convert to an attributed string.
    /// - Returns: An attributed string representation of the title, or `nil` if the title is `nil`.
    func text(for title: Title?) -> NSAttributedString? {
        if let text = title as? String {
            return attributedTitle(text)
        }
        if #available(iOS 15, *), let text = title as? AttributedString {
            return NSAttributedString(text)
        }
        return title as? NSAttributedString
    }

    /// Converts a message to an attributed string for display.
    ///
    /// This method handles the conversion of various message types to attributed strings,
    /// applying the appropriate formatting based on the message configuration.
    ///
    /// - Parameter message: The message to convert to an attributed string.
    /// - Returns: An attributed string representation of the message, or `nil` if the message is `nil`.
    func text(for message: Message?) -> NSAttributedString? {
        if let text = message as? String {
            return attributedMessage(text)
        }
        if #available(iOS 15, *), let text = message as? AttributedString {
            return NSAttributedString(text)
        }
        return message as? NSAttributedString
    }
}

/// An extension that provides attributed string creation methods for message alerts.
///
/// This extension handles the creation of attributed strings with proper formatting
/// for title and message text, applying the configuration settings for typography and styling.
extension MessageAlert {

    /// The attributed string attributes for the title text.
    ///
    /// This computed property returns the attributes dictionary that should be applied
    /// to the title text, including font, color, alignment, and paragraph styling.
    private var titleAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let titleConfiguration = titleConfiguration

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        paragraphStyle.alignment = titleConfiguration.alignment
        attributes[.font] = titleConfiguration.font
        attributes[.foregroundColor] = titleConfiguration.color
        attributes[.paragraphStyle] = paragraphStyle.copy()
        return attributes
    }

    /// The attributed string attributes for the message text.
    ///
    /// This computed property returns the attributes dictionary that should be applied
    /// to the message text, including font, color, alignment, and paragraph styling.
    private var messageAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let messageConfiguration = messageConfiguration

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.05
        paragraphStyle.alignment = messageConfiguration.alignment
        attributes[.font] = messageConfiguration.font
        attributes[.foregroundColor] = messageConfiguration.color
        attributes[.paragraphStyle] = paragraphStyle.copy()
        return attributes
    }

    /// Creates an attributed string for the specified title text.
    ///
    /// This method applies the title configuration attributes to the provided text,
    /// creating a properly formatted attributed string for display.
    ///
    /// - Parameter title: The title text to format.
    /// - Returns: An attributed string with the title configuration applied.
    func attributedTitle(_ title: String) -> NSAttributedString {
        let range = NSMakeRange(0, title.count)
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttributes(titleAttributes, range: range)
        return NSAttributedString(attributedString: attributedTitle)
    }

    /// Creates an attributed string for the specified message text.
    ///
    /// This method applies the message configuration attributes to the provided text,
    /// creating a properly formatted attributed string for display.
    ///
    /// - Parameter message: The message text to format.
    /// - Returns: An attributed string with the message configuration applied.
    func attributedMessage(_ message: String) -> NSAttributedString {
        let range = NSMakeRange(0, message.count)
        let attributedMessage = NSMutableAttributedString(string: message)
        attributedMessage.addAttributes(messageAttributes, range: range)
        return NSAttributedString(attributedString: attributedMessage)
    }
}
