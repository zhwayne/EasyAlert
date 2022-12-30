//
//  Toast.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/13.
//

import Foundation

public struct Toast {
        
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
        // 5 个字以内显示时长固定位一秒
        let threshold = 5
        let minimumDuratuon: TimeInterval = 1
        
        if text.count <= threshold { return minimumDuratuon }
        let leftTextLen = text.count - threshold
        let extDuration = Double(leftTextLen) * 0.13
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
        position: Position = .bottom
    ) {
        guard let string = message.attributedText?.string else { return }
        var duration = duration
        if duration == 0 { duration = Toast.duration(of: string)}
        
        if dismissWork != nil {
            dismissWork?.cancel()
            dismissWork = nil
        }
        
        if let alert = alert {
            alert.rawCustomView.label.attributedText = message.attributedText
        } else {
            alert = ToastAlert(message: message)
            if var coordinator = alert?.transitionCoordinator as? ToastTransitionCoordinator {
                coordinator.position = position
                alert?.transitionCoordinator = coordinator
            }
            alert?.show()
        }
        dismissAfter(duration: duration)
    }
}
