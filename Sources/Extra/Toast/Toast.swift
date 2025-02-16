//
//  Toast.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

@MainActor public struct Toast {
    
    private static var alert: ToastAlert?
    
    private static var dismissWork: DispatchWorkItem?
    
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
    
    private static func duration(of text: String) -> TimeInterval {
        // 5 个字以内显示时长固定位 1.5 秒
        let threshold = 5
        let minimumDuratuon: TimeInterval = 1.5
        
        if text.count <= threshold { return minimumDuratuon }
        let leftTextLen = text.count - threshold
        let extDuration = Double(leftTextLen) * 0.14
        return minimumDuratuon + extDuration
    }
}

extension Toast {
    
    public enum Position {
        case center, bottom
    }
}

extension Toast {
    
    public static func show(
        _ message: Message,
        duration: TimeInterval = 0,
        position: Position = .bottom,
        penetrationScope: PenetrationScope = .all
    ) {
        guard let string = Toast.text(for: message)?.string else { return }
        var duration = duration
        if duration == 0 { duration = Toast.duration(of: string)}
        
        if dismissWork != nil {
            dismissWork?.cancel()
            dismissWork = nil
        }
        
        if let alert = alert {
            alert.rawCustomView.label.attributedText = Toast.text(for: message)
        } else {
            alert = ToastAlert(message: message)
        }
        
        if let layoutModifier = alert?.layoutModifier as? ToastLayout {
            layoutModifier.position = position
        }
        
        let parameters = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: 1.0, timingParameters: parameters)
        animator.addAnimations {
            alert?.rawCustomView.indicator.isHidden = duration != .infinity
            alert?.rawCustomView.indicator.alpha = duration == .infinity ? 1 : 0
        }
        animator.startAnimation()
        
        alert?.backdropProvider.penetrationScope = penetrationScope
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
        dismissAfter(duration: duration)
    }
    
    @available(iOS 13.0, *)
    public static func dismiss() async {
        if let alert = alert {
            await alert.dismiss()
        }
    }
    
    public static func dismiss(completion: (() -> Void)? = nil) {
        if let alert = alert {
            alert.dismiss(completion: completion)
        } else {
            completion?()
        }
    }
}
