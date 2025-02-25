//
//  AlertContent.swift
//  EasyAlert
//
//  Created by iya on 2021/7/27.
//

import UIKit

/// An `UIView` instance that implements the `AlertContent` protocol can be displayed by Alert
/// and has the ability to turn off alerts for free.
///
/// Here is a simple example of how to implement a custom alert:
///
/// ```
/// final class MyAlert: Alert {
///
///     private final class ContentView: UIImageView, AlertContent {
///
///         override init(image: UIImage?) {
///             super.init(image: image)
///             isUserInteractionEnabled = true
///             let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
///             addGestureRecognizer(tap)
///
///             // Add your code here to customize the appearance of the view..
///             // ...
///         }
///
///         @objc private func handleTap(_ tap: UITapGestureRecognizer) {
///             dismiss()
///         }
///     }
///
///     required init(image: UIImage) {
///         super.init(content: ContentView(image: image))
///     }
/// }
///
/// // Usage:
/// let alert = MyAlert(image: image)
/// alert.show()
///
public protocol AlertContent: Dismissible { }
