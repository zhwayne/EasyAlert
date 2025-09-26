//
//  Proxy.swift
//  EasyAlert
//
//  Created by iya on 2021/12/21.
//

import UIKit

/// A proxy object that forwards method calls to a target object.
///
/// `Proxy` acts as a transparent wrapper around another object, forwarding all method calls
/// to the target object while maintaining the same interface. This is useful for creating
/// weak references or intercepting method calls.
internal class Proxy: NSObject /* & NSProxy */ {

    /// The target object that receives forwarded method calls.
    private weak var target: NSObject!

    /// Creates a proxy with the specified target object.
    ///
    /// - Parameter target: The object to forward method calls to.
    required init(target: NSObject) {
        super.init()
        self.target = target
    }

    /// Returns the target object for method forwarding.
    ///
    /// - Parameter aSelector: The selector of the method being called.
    /// - Returns: The target object to forward the method call to.
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }

    /// Forwards equality comparison to the target object.
    ///
    /// - Parameter object: The object to compare with.
    /// - Returns: `true` if the target object is equal to the specified object.
    override func isEqual(_ object: Any?) -> Bool {
        return target.isEqual(object)
    }

    /// Forwards hash calculation to the target object.
    ///
    /// - Returns: The hash value of the target object.
    override var hash: Int {
        return target.hash
    }

    /// Forwards superclass access to the target object.
    ///
    /// - Returns: The superclass of the target object.
    override var superclass: AnyClass? {
        return target.superclass
    }

    /// Indicates that this object is a proxy.
    ///
    /// - Returns: Always `true` for proxy objects.
    override func isProxy() -> Bool {
        return true
    }

    /// Forwards class membership check to the target object.
    ///
    /// - Parameter aClass: The class to check membership for.
    /// - Returns: `true` if the target object is a kind of the specified class.
    override func isKind(of aClass: AnyClass) -> Bool {
        return target.isKind(of: aClass)
    }

    /// Forwards class membership check to the target object.
    ///
    /// - Parameter aClass: The class to check membership for.
    /// - Returns: `true` if the target object is a member of the specified class.
    override func isMember(of aClass: AnyClass) -> Bool {
        return target.isMember(of: aClass)
    }

    /// Forwards protocol conformance check to the target object.
    ///
    /// - Parameter aProtocol: The protocol to check conformance for.
    /// - Returns: `true` if the target object conforms to the specified protocol.
    override func conforms(to aProtocol: Protocol) -> Bool {
        return target.conforms(to: aProtocol)
    }

    /// Forwards method response check to the target object.
    ///
    /// - Parameter aSelector: The selector to check for.
    /// - Returns: `true` if the target object responds to the specified selector.
    override func responds(to aSelector: Selector!) -> Bool {
        return target.responds(to: aSelector)
    }

    /// Forwards description to the target object.
    ///
    /// - Returns: The description of the target object.
    override var description: String {
        return target.description
    }

    /// Forwards debug description to the target object.
    ///
    /// - Returns: The debug description of the target object.
    override var debugDescription: String {
        return target.debugDescription
    }
}
