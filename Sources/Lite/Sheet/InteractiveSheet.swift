//
//  InteractiveSheet.swift
//  EasyAlert
//
//  Created by Assistant on 2024/12/19.
//

import UIKit

/// A sheet that supports interactive drag-to-dismiss functionality.
///
/// `InteractiveSheet` extends the base `Sheet` class to provide gesture-driven
/// dismissal animations. Users can drag the sheet down to dismiss it, with
/// real-time visual feedback. The sheet intelligently ignores drag gestures
/// when they occur within RepresentationMark areas (like action buttons).
open class InteractiveSheet: Sheet {
    
    /// The pan gesture recognizer for drag-to-dismiss functionality.
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
    
    /// The coordinator that handles gesture delegate methods.
    private var coordinator: Coordinator!
    
    /// The drag threshold that determines when to complete the dismissal.
    private let dragThreshold: CGFloat = 100.0
    
    /// The maximum drag distance before the sheet is automatically dismissed.
    private let maxDragDistance: CGFloat = 200.0
    
    /// The current drag progress (0.0 to 1.0).
    private var dragProgress: CGFloat = 0.0
    
    /// Whether the sheet is currently being dragged.
    private var isDragging: Bool = false
    
    /// The original transform of the presented view before dragging started.
    private var originalTransform: CGAffineTransform = .identity
    
    /// Creates a new interactive sheet with the specified content.
    ///
    /// - Parameter content: The content to display in the sheet.
    public override init(content: AlertContent) {
        super.init(content: content)
        // Use the interactive sheet animator that supports progress updates
        self.animator = InteractiveSheetAnimator()
        
        setupPanGesture()
        
        // Create the coordinator for gesture delegate handling
        self.coordinator = Coordinator(interactiveSheet: self)
    }
    
    /// Called after the sheet is shown.
    ///
    /// This method enables the pan gesture recognizer to allow drag-to-dismiss functionality.
    open override func didShow() {
        super.didShow()
        panGestureRecognizer.isEnabled = true
    }
    
    /// Called before the sheet is dismissed.
    ///
    /// This method disables the pan gesture recognizer to prevent interference during dismissal.
    open override func willDismiss() {
        super.willDismiss()
        panGestureRecognizer.isEnabled = false
    }
    
    // MARK: - Private Methods
    
    private func setupPanGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = coordinator
        panGestureRecognizer.isEnabled = false
        
        // Add the gesture to the presented view so it can capture all touches
        presentedView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: presentedView)
        let velocity = gesture.velocity(in: presentedView)
        
        switch gesture.state {
        case .began:
            guard !isDragging else { return }
            startDragging()
            
        case .changed:
            guard isDragging else { return }
            updateDragProgress(translation: translation, velocity: velocity)
            
        case .ended, .cancelled:
            guard isDragging else { return }
            endDragging(translation: translation, velocity: velocity)
            
        default:
            break
        }
    }
    
    private func startDragging() {
        isDragging = true
        originalTransform = presentedView.transform
        
        // Store the current animator state
        if let interactiveAnimator = animator as? InteractiveAnimator {
            // Pause any ongoing animation
            interactiveAnimator.updateProgress(0)
        }
    }
    
    private func updateDragProgress(translation: CGPoint, velocity: CGPoint) {
        // Only respond to downward drags
        guard translation.y > 0 else { return }
        
        // Calculate drag progress
        dragProgress = min(1.0, translation.y / maxDragDistance)
        
        // Apply visual feedback
        let dragTransform = CGAffineTransform(translationX: 0, y: translation.y)
        let scaleTransform = CGAffineTransform(scaleX: 1.0 - dragProgress * 0.05, y: 1.0 - dragProgress * 0.05)
        
        presentedView.transform = originalTransform.concatenating(dragTransform).concatenating(scaleTransform)
        
        // Update dimming view alpha - find the dimming view in the container
        let dimmingAlpha = max(0.1, 1.0 - dragProgress * 0.8)
        for subview in containerView.subviews {
            if subview is DimmingView {
                subview.alpha = dimmingAlpha
                break
            }
        }
        
        // Update animator progress for smooth transition
        if let interactiveAnimator = animator as? InteractiveAnimator {
            interactiveAnimator.updateProgress(dragProgress)
        }
    }
    
    private func endDragging(translation: CGPoint, velocity: CGPoint) {
        isDragging = false
        
        let shouldDismiss = translation.y > dragThreshold || velocity.y > 500
        
        if shouldDismiss {
            // Complete dismissal
            dismiss()
        } else {
            // Spring back to original position
            springBackToOriginalPosition()
        }
    }
    
    private func springBackToOriginalPosition() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.presentedView.transform = self.originalTransform
                
                // Restore dimming view alpha
                for subview in self.containerView.subviews {
                    if subview is DimmingView {
                        subview.alpha = 1.0
                        break
                    }
                }
            },
            completion: { _ in
                self.dragProgress = 0.0
                
                // Reset animator progress
                if let interactiveAnimator = self.animator as? InteractiveAnimator {
                    interactiveAnimator.updateProgress(0)
                }
            }
        )
    }
    
    /// A coordinator that handles gesture recognition delegate methods for InteractiveSheet.
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        weak var interactiveSheet: InteractiveSheet?
        
        init(interactiveSheet: InteractiveSheet) {
            self.interactiveSheet = interactiveSheet
            super.init()
        }
        
        // MARK: - UIGestureRecognizerDelegate
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            guard let interactiveSheet = interactiveSheet else { return false }
            guard gestureRecognizer == interactiveSheet.panGestureRecognizer else { return true }
            
            // Check if the touch is within a RepresentationMark area
            let touchLocation = touch.location(in: interactiveSheet.presentedView)
            
            // Find all RepresentationMark views in the hierarchy
            let representationViews = interactiveSheet.presentedView.findActionRepresentationViews() ?? []
            
            for representationView in representationViews {
                let convertedFrame = representationView.convert(representationView.bounds, to: interactiveSheet.presentedView)
                if convertedFrame.contains(touchLocation) {
                    // Touch is within a RepresentationMark area, don't start the pan gesture
                    return false
                }
            }
            
            // Touch is not within any RepresentationMark area, allow the pan gesture
            return true
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let interactiveSheet = interactiveSheet else { return false }
            guard gestureRecognizer == interactiveSheet.panGestureRecognizer else { return false }
            
            // Allow simultaneous recognition with scroll view gestures
            if otherGestureRecognizer.view is UIScrollView {
                // Only allow if the scroll view is at the top of its content
                if let scrollView = otherGestureRecognizer.view as? UIScrollView {
                    return scrollView.contentOffset.y <= 0
                }
            }
            
            return false
        }
    }
}


