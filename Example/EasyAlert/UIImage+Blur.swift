//
//  UIImage+Blur.swift
//  EasyAlert_Example
//
//  Created by iya on 2022/5/28.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import CoreImage

extension CGImage {
    
    func blur(radius: CGFloat) -> CGImage? {
        
        let ciContext = CIContext()
        let ciImage = CIImage(cgImage: self)
        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: "inputRadius")
        guard let result = filter.outputImage else { return nil }
        let image = ciContext.createCGImage(result, from: CGRect(x: 0, y: 0, width: width, height: height))
        return image
    }
}

extension UIImage {
    
    func blur(radius: CGFloat) -> UIImage? {
        guard let cgImaqge = self.cgImage?.blur(radius: radius) else { return nil }
        return UIImage(cgImage: cgImaqge)
    }
}
