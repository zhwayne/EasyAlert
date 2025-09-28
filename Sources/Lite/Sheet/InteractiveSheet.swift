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

    /// The scroll view under the initial touch, if any.
    private weak var activeScrollView: UIScrollView?
    
    /// Whether the sheet has taken over from an inner scroll view during this drag.
    private var hasCapturedScroll: Bool = false
    
    /// Original scrollEnabled state before capture, to restore on end.
    private var capturedScrollOriginalIsScrollEnabled: Bool?

    /// Whether the sheet actually applied any transform during this gesture.
    private var didApplyDrag: Bool = false

    /// The top grabber indicator managed by the sheet.
    private var grabberView: UIView?
    
    /// Creates a new interactive sheet with the specified content.
    ///
    /// - Parameter content: The content to display in the sheet.
    public override init(content: AlertContent) {
        super.init(content: content)
        // Create the coordinator for gesture delegate handling
        self.coordinator = Coordinator(interactiveSheet: self)

        setupPanGesture()
    }
    
    /// Called before the sheet is shown.
    ///
    /// Install grabber earlier so it's part of the initial layout and animation.
    open override func willShow() {
        super.willShow()
        installGrabberIfNeeded()
    }

    /// Called after the sheet is shown.
    ///
    /// Enable the pan gesture recognizer to allow drag-to-dismiss functionality.
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

    private func installGrabberIfNeeded() {
        guard grabberView == nil else { return }
        let grabber = UIView()
        grabber.translatesAutoresizingMaskIntoConstraints = false
        grabber.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.3)
        grabber.layer.cornerRadius = 2.5
        grabber.layer.masksToBounds = true
        presentedView.addSubview(grabber)
        let topAnchor = presentedView.topAnchor
        NSLayoutConstraint.activate([
            grabber.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            grabber.centerXAnchor.constraint(equalTo: presentedView.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 36),
            grabber.heightAnchor.constraint(equalToConstant: 5)
        ])
        grabberView = grabber
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        // Use containerView as reference to avoid feedback from transforming presentedView
        let translation = gesture.translation(in: containerView)
        let velocity = gesture.velocity(in: containerView)

        switch gesture.state {
        case .began:
            guard !isDragging else { return }
            startDragging(gesture)

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
    
    private func startDragging(_ gesture: UIPanGestureRecognizer) {
        isDragging = true
        originalTransform = presentedView.transform
        hasCapturedScroll = false
        capturedScrollOriginalIsScrollEnabled = nil
        didApplyDrag = false

        // Capture the scroll view under the initial touch if present
        let location = gesture.location(in: presentedView)
        if let hitView = presentedView.hitTest(location, with: nil) {
            activeScrollView = Coordinator.scrollView(from: hitView)
        } else {
            activeScrollView = nil
        }
        
        // Store the current animator state
        if let interactiveAnimator = animator as? InteractiveAnimator {
            // Pause any ongoing animation
            interactiveAnimator.updateProgress(0)
        }
    }
    
    private func updateDragProgress(translation: CGPoint, velocity: CGPoint) {
        // If there is an active scroll view: coordinate with it
        if let scrollView = activeScrollView {
            if hasCapturedScroll {
                // While captured, treat the scroll view as pinned to top
                let topY = -scrollView.adjustedContentInset.top
                if scrollView.contentOffset.y < topY {
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: topY), animated: false)
                }
                // Ensure scroll is disabled while captured to avoid jitter
                if scrollView.isScrollEnabled { scrollView.isScrollEnabled = false }
                // Allow both downward and upward motions, but never translate above origin
                let ty = max(0, translation.y)
                applySheetDrag(translationY: ty)
                return
            } else {
                if translation.y > 0 {
                    // Downward drag: capture if at or beyond top
                    let topY = -scrollView.adjustedContentInset.top
                    if scrollView.contentOffset.y <= topY + 0.5 {
                        beginCapture(scrollView)
                        let ty = max(0, translation.y)
                        applySheetDrag(translationY: ty)
                        return
                    } else {
                        // Not yet at top, let the scroll view consume
                        return
                    }
                } else {
                    // Upward drag before capture: let the scroll view consume
                    return
                }
            }
        } else {
            // No scroll view under touch: allow downward, and clamp upward to zero
            let ty = max(0, translation.y)
            guard ty > 0 else { return }
            applySheetDrag(translationY: ty)
            return
        }
    }

    private func applySheetDrag(translationY: CGFloat) {
        didApplyDrag = true
        // Calculate drag progress
        dragProgress = min(1.0, translationY / maxDragDistance)

        // Apply visual feedback
        let dragTransform = CGAffineTransform(translationX: 0, y: translationY)
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
    }

    private func beginCapture(_ scrollView: UIScrollView) {
        guard !hasCapturedScroll else { return }
        hasCapturedScroll = true
        // Save state and disable scrolling to prevent competing pan updates
        if capturedScrollOriginalIsScrollEnabled == nil {
            capturedScrollOriginalIsScrollEnabled = scrollView.isScrollEnabled
        }
        scrollView.isScrollEnabled = false
        // Snap to top to remove any tiny overscroll
        let topY = -scrollView.adjustedContentInset.top
        if scrollView.contentOffset.y < topY {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: topY), animated: false)
        }
    }

    private func endCapture() {
        if let scrollView = activeScrollView, let wasEnabled = capturedScrollOriginalIsScrollEnabled {
            scrollView.isScrollEnabled = wasEnabled
        }
        activeScrollView = nil
        hasCapturedScroll = false
        capturedScrollOriginalIsScrollEnabled = nil
    }
    
    private func endDragging(translation: CGPoint, velocity: CGPoint) {
        isDragging = false
        // If we never applied any sheet transform, don't attempt dismiss/spring.
        if !didApplyDrag {
            endCapture()
            return
        }
        endCapture()
        
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

            // Allow the pan gesture; coordination with scroll views happens during updates
            return true
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let interactiveSheet = interactiveSheet else { return false }
            guard gestureRecognizer == interactiveSheet.panGestureRecognizer else { return false }

            // While captured by the sheet, avoid simultaneous recognition to prevent jitter
            if interactiveSheet.hasCapturedScroll { return false }

            // Allow simultaneous with scroll views before capture for smooth handoff
            if let _ = otherGestureRecognizer.view as? UIScrollView { return true }
            if otherGestureRecognizer is UIPanGestureRecognizer,
               otherGestureRecognizer.view is UIScrollView { return true }
            return false
        }

        static func scrollView(from view: UIView?) -> UIScrollView? {
            var current: UIView? = view
            while let v = current {
                if let sv = v as? UIScrollView { return sv }
                current = v.superview
            }
            return nil
        }
    }
}
