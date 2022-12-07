//
//  TransitionCoordinator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

public enum Width {
    
    case fixed(CGFloat)         // equal to value.
    
    case flexible(CGFloat)      // less than or equal to value.
    
    case multiplied(CGFloat)    // multiples of superview's width.
}

public enum Height {
    
    case automic
    
    case greaterThanOrEqualTo(CGFloat)
}

public struct Size {
    
    public var width: Width
    
    public var height: Height
}

public struct TransitionCoordinatorContext {
    
    public let container: UIView
    
    public let dimmingView: UIView
    
    public let interfaceOrientation: UIInterfaceOrientation
    
    public let frame: CGRect
}

public protocol TransitionCoordinator {
    
    var duration: TimeInterval { get set }

    var size: Size { get set }
    
    func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void)
    
    func dismiss(context: TransitionCoordinatorContext, completion: @escaping () -> Void)
    
    func update(context: TransitionCoordinatorContext)
}

@available(iOS 13.0, *)
extension TransitionCoordinator {
    
    func show(context: TransitionCoordinatorContext) async {
        await withUnsafeContinuation({ continuation in
            show(context: context) {
                continuation.resume()
            }
        })
    }
    
    func dismiss(context: TransitionCoordinatorContext) async {
        await withUnsafeContinuation({ continuation in
            dismiss(context: context) {
                continuation.resume()
            }
        })
    }
}
