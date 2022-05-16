//
//  DeviceOrientationTarget.swift
//  EasyAlert
//
//  Created by iya on 2021/12/21.
//

import Foundation

extension Alert {
    
    final class DeviceOrientationTarget: NSObject {
        
        private lazy var proxy = Proxy(target: self)
        
        var orientationDidChangeBlock: (() -> Void)?
        
        deinit {
            NotificationCenter.default.removeObserver(proxy)
        }
        
        override init() {
            super.init()
            
            NotificationCenter.default.addObserver(proxy,
                                                   selector: #selector(handleDeviceOrientationNotifications(_:)),
                                                   name: UIDevice.orientationDidChangeNotification,
                                                   object: nil)
        }
        
        @objc
        private func handleDeviceOrientationNotifications(_ note: Notification) {
            orientationDidChangeBlock?()
        }
    }
}
