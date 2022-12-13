//
//  Toast.swift
//  EasyAlert
//
//  Created by 张尉 on 2022/12/13.
//

import Foundation

public final class Toast {
    
    private static let shared = Toast()
    
    private var alert: ToastAlert?
    
    private var dismissWork: DispatchWorkItem?
    
    private func show(_ message: Message, duration: TimeInterval = 0) {
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
            alert?.show()
        }
        dismissAfter(duration: duration)
    }
    
    private func dismissAfter(duration: TimeInterval) {
        dismissWork = DispatchWorkItem(qos: .userInteractive, block: { [weak self] in
            self?.alert?.dismiss()
            self?.alert = nil
            self?.dismissWork = nil
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: dismissWork!)
    }
    
    public static func show(_ message: Message, duration: TimeInterval = 0) {
        shared.show(message, duration: duration)
    }
}

extension Toast {
    
    private static func duration(of text: String) -> TimeInterval {
        // 7 个字以内显示时长固定位一秒
        let threshold = 7
        let minimumDuratuon: TimeInterval = 1
        
        if text.count <= threshold { return minimumDuratuon }
        let leftTextLen = text.count - threshold
        let extDuration = log10(Double(leftTextLen) * 1.13) * 1.25
        return minimumDuratuon + extDuration
    }
}
