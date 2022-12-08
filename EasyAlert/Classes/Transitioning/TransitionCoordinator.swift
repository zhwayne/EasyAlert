//
//  TransitionCoordinator.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

public enum Width {
    // equal to value.
    case fixed(CGFloat)
    // less than or equal to value.
    case flexible(CGFloat)
    // multiples of superview's width.
    case multiplied(CGFloat, maximumWidth: CGFloat = 0)
}

public enum Height {
    
    case automic
    
    case greaterThanOrEqualTo(CGFloat)
}

public struct LayoutGuide {
    
    public var width: Width
    
    public var height: Height = .automic
    
    public var edgeInsets: UIEdgeInsets = .zero
    
    // Only for Sheet.
    public var ignoreBottomSafeArea: Bool = true
}

public struct TransitionCoordinatorContext {
    
    public let container: UIView
    
    public let backgroundView: UIView
    
    public let dimmingView: UIView
    
    public let interfaceOrientation: UIInterfaceOrientation
    
    public let frame: CGRect
}

public protocol TransitionCoordinator {
    
    var duration: TimeInterval { get set }

    var layoutGuide: LayoutGuide { get set }
    
    func show(context: TransitionCoordinatorContext, completion: @escaping () -> Void)
    
    func dismiss(context: TransitionCoordinatorContext, completion: @escaping () -> Void)
    
    mutating func update(context: TransitionCoordinatorContext)
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
