//
//  BlurEffectView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

class BlurEffectView: UIVisualEffectView {
    
    private let intensity: Float
    
    /// Create visual effect view with given effect and its intensity
    ///
    /// - Parameters:
    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
    init(effect: UIVisualEffect, intensity: Float) {
        self.intensity = intensity
        super.init(effect: nil)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect }
        animator.fractionComplete = CGFloat(intensity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Private
    var animator: UIViewPropertyAnimator!
    
    override var alpha: CGFloat {
        didSet {
            animator.fractionComplete = alpha * CGFloat(intensity)
        }
    }
}
