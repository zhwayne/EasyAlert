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
        position: Position = .center,
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
            if var aniamtor = alert?.transitionAniamtor as? ToastTransitionAnimator {
                aniamtor.position = position
                alert?.transitionAniamtor = aniamtor
            }
            alert?.show()
        }
        alert?.backdropProvider.penetrationScope = penetrationScope
        dismissAfter(duration: duration)
    }
}
