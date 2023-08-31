//
//  DimmingView.swift
//  EasyAlert
//
//  Created by iya on 2022/5/28.
//

import UIKit

/**
 A view used to present a content view that is laid out to fit the entire bounds of
 the dimming view. This view is typically used as a background for popovers or
 alert-style presentations, providing a visual cue that the content view is the
 primary focus and the rest of the interface is dimmed.
 
 To use, simply set the `contentView` property to the desired content view, and the
 dimming view will automatically resize and position it to fill its bounds. If the
 `contentView` property is set to `nil`, the dimming view will not display any content.
 */
class DimmingView : UIView {
    
    /// The content view to be presented in the dimming view. Setting this property
    /// automatically resizes and positions the content view to fit the entire bounds
    /// of the dimming view.
    var contentView: UIView? {
        didSet {
            guard oldValue != contentView else { return }
            oldValue?.removeFromSuperview()
            guard let contentView = contentView else { return }
            addSubview(contentView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView?.frame = bounds
    }
}

