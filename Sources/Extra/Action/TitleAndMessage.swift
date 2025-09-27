//
//  TitleAndMessage.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import Foundation

/// A protocol that defines types that can be used as alert titles.
///
/// Types conforming to `Title` can be used to provide title content for alerts.
/// This protocol enables type-safe title handling in the alert system.
public protocol Title { }

/// A protocol that defines types that can be used as alert messages.
///
/// Types conforming to `Message` can be used to provide message content for alerts.
/// This protocol enables type-safe message handling in the alert system.
public protocol Message { }

/// An extension that allows `String` to be used as both title and message content.
///
/// This extension enables `String` instances to be used directly as alert titles
/// and messages without additional conversion.
extension String: Title, Message { }

/// An extension that allows `NSAttributedString` to be used as both title and message content.
///
/// This extension enables `NSAttributedString` instances to be used directly as alert titles
/// and messages, providing support for rich text formatting.
extension NSAttributedString: Title, Message { }

/// An extension that allows `AttributedString` to be used as both title and message content.
///
/// This extension enables `AttributedString` instances to be used directly as alert titles
/// and messages, providing support for modern Swift attributed string formatting.
/// Available on iOS 15.0 and later.
@available(iOS 15.0, *)
extension AttributedString: Title, Message { }
