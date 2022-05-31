//
//  SheetTransitioning.swift
//  EasyAlert
//
//  Created by iya on 2022/5/31.
//

import Foundation

open class SheetTransitioning : Transitioning {
    
    public var duration: TimeInterval = 0.25
    
    public var layoutSize: LayoutSize = LayoutSize(
        width: .multiplied(1),
        height: .automic
    )
    
    public func show(context: TransitioningContext, completion: @escaping () -> Void) {
        context.container.layoutIfNeeded()
        let height = context.container.bounds.height
        context.container.transform = CGAffineTransform(translationX: 0, y: height)
        context.dimmingView.alpha = 0
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            context.dimmingView.alpha = 1
            context.container.transform = .identity
        } completion: { _ in
            completion()
        }
    }
    
    public func dismiss(context: TransitioningContext, completion: @escaping () -> Void) {
        context.container.layoutIfNeeded()
        let height = context.container.bounds.height
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            context.dimmingView.alpha = 0
            context.container.transform = CGAffineTransform(translationX: 0, y: height)
        } completion: { finished in
            completion()
        }
    }
    
    public func update(context: TransitioningContext) {
        context.container.snp.remakeConstraints { maker in
            switch layoutSize.width {
            case let .fixed(value): maker.width.equalTo(value)
            case let .flexible(value): maker.width.lessThanOrEqualTo(value)
            case let .multiplied(value):
                if context.interfaceOrientation.isPortrait {
                    maker.width.equalToSuperview().multipliedBy(value)
                } else {
                    maker.width.equalTo(context.container.superview!.snp.height).multipliedBy(value).priority(.high)
                }
            }
            if case let .greaterThanOrEqualTo(value) = layoutSize.height {
                maker.height.greaterThanOrEqualTo(value)
            }
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
}
