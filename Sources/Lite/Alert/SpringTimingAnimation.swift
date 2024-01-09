//
//  SpringTimingAnimation.swift
//
//
//  Created by iya on 2024/1/9.
//

import UIKit

func withSpringTimingAnimation(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
    let animator = UIViewPropertyAnimator(duration: 1, timingParameters: UISpringTimingParameters())
    animator.addAnimations(animations)
    if let completion {
        animator.addCompletion { position in
            completion(position == .end)
        }
    }
    animator.startAnimation()
}
