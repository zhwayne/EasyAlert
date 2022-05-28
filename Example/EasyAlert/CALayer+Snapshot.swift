//
//  CALayer+Snapshot.swift
//  EasyAlert_Example
//
//  Created by iya on 2022/5/28.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

extension CALayer {
    
    func snapshot(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        if let ctx = UIGraphicsGetCurrentContext() {
            render(in: ctx)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                return image
            }
        }
        
        let render = UIGraphicsImageRenderer(bounds: bounds)
        let image = render.image { [weak self] renderContext in
            self?.render(in: renderContext.cgContext)
        }
        return image
    }
}

