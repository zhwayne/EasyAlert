//
//  NotificationToken.swift
//  EasyAlert
//
//  Created by iya on 2022/3/24.
//

import Foundation

/// A token that manages notification observer lifecycle.
///
/// `NotificationToken` automatically removes the associated notification observer
/// when it's deallocated, preventing memory leaks and ensuring proper cleanup.
internal final class NotificationToken: NSObject {

    /// The notification center that the observer is registered with.
    let notificationCenter: NotificationCenter
    
    /// The observer token returned by the notification center.
    let token: Any

    /// Creates a notification token with the specified notification center and observer token.
    ///
    /// - Parameters:
    ///   - notificationCenter: The notification center that the observer is registered with.
    ///   - token: The observer token returned by the notification center.
    init(notificationCenter: NotificationCenter = .default, token: Any) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    deinit {
        notificationCenter.removeObserver(token)
    }
}

extension NotificationCenter {
    /// A convenience method for adding notification observers that returns a `NotificationToken`.
    ///
    /// This method automatically manages the observer lifecycle by returning a token that
    /// removes the observer when deallocated.
    ///
    /// - Parameters:
    ///   - name: The name of the notification to observe.
    ///   - obj: The object whose notifications the observer wants to receive.
    ///   - queue: The operation queue on which to execute the block.
    ///   - block: The block to execute when the notification is received.
    /// - Returns: A `NotificationToken` that manages the observer lifecycle.
    func observe(
        name: NSNotification.Name?,
        object obj: Any? = nil,
        queue: OperationQueue = .main,
        using block: @escaping (Notification) -> ())
    -> NotificationToken
    {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token)
    }
}
