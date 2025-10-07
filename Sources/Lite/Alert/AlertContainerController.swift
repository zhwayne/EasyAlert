//
//  AlertContainerController.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import UIKit

/// A view controller that manages the container for alert content and handles touch interactions.
///
/// `AlertContainerController` serves as the container for alert content and provides
/// specialized touch handling for interactive elements within the alert. It manages
/// the presentation of alert content and handles touch events for representation views.
final class AlertContainerController: UIViewController {

    /// The alert that this container controller is managing.
    private(set) weak var alert: Alert?

    /// Disables automatic forwarding of appearance methods to child view controllers.
    override var shouldAutomaticallyForwardAppearanceMethods: Bool { false }

    /// The currently active representation view that is being tracked for touch events.
    private var activeRepresentationView: (any UIControl & RepresentationMark)?

    /// The haptic feedback generator for providing tactile feedback during interactions.
    private let feedback = UISelectionFeedbackGenerator()

    /// Creates a new alert container controller for the specified alert.
    ///
    /// - Parameter alert: The alert that this container will manage.
    init(alert: Alert) {
        super.init(nibName: nil, bundle: nil)
        self.alert = alert
    }

    /// This initializer is not supported.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Called after the view controller's view is loaded into memory.
    ///
    /// This method sets up the view controller's view for the frame-based layout
    /// system used by the surrounding alert infrastructure.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = []
        // Do any additional setup after loading the view.
    }

    /// Called when the view controller's view is about to be added to the view hierarchy.
    ///
    /// This method fixes safe area insets for child view controllers that may not
    /// receive proper updates when they're partially visible.
    ///
    /// - Parameter animated: Whether the appearance is animated.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Fix for child controllers not receiving an update on safe area insets
        // when they're partially not showing
        for child in children {
            let preInsets = child.additionalSafeAreaInsets
            child.additionalSafeAreaInsets = view.safeAreaInsets
            child.additionalSafeAreaInsets = preInsets
        }
    }

    /// Called when touches begin in the view controller's view.
    ///
    /// This method resets any active representation view and begins tracking
    /// touch events for interactive elements within the alert.
    ///
    /// - Parameters:
    ///   - touches: The touches that began.
    ///   - event: The event that contains the touches.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetRepresentationView()
        if let touch = touches.first {
            handleTracking(touch, with: event, isTracking: false)
        }
        super.touchesBegan(touches, with: event)
    }

    /// Called when touches end in the view controller's view.
    ///
    /// This method handles the completion of touch interactions, including
    /// sending actions to the active representation view if it was highlighted.
    ///
    /// - Parameters:
    ///   - touches: The touches that ended.
    ///   - event: The event that contains the touches.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer { activeRepresentationView = nil }
        if let activeRepresentationView, activeRepresentationView.isHighlighted {
            activeRepresentationView.isHighlighted = false
            activeRepresentationView.sendActions(for: .touchUpInside)
        }
        super.touchesEnded(touches, with: event)
    }

    /// Called when touches are cancelled in the view controller's view.
    ///
    /// This method resets the active representation view when touch events
    /// are cancelled, ensuring proper cleanup of touch state.
    ///
    /// - Parameters:
    ///   - touches: The touches that were cancelled.
    ///   - event: The event that contains the touches.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetRepresentationView()
        super.touchesCancelled(touches, with: event)
    }

    /// Called when touches move in the view controller's view.
    ///
    /// This method continues tracking touch events as they move across
    /// the view, updating the active representation view accordingly.
    ///
    /// - Parameters:
    ///   - touches: The touches that moved.
    ///   - event: The event that contains the touches.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            handleTracking(touch, with: event, isTracking: true)
        }
        super.touchesMoved(touches, with: event)
    }

    /// Handles touch tracking for representation views within the alert.
    ///
    /// This method finds and tracks interactive elements within the alert,
    /// providing visual feedback and haptic feedback as appropriate.
    ///
    /// - Parameters:
    ///   - touch: The touch to track.
    ///   - event: The event containing the touch.
    ///   - isTracking: Whether this is a tracking touch (moved) or initial touch (began).
    private func handleTracking(_ touch: UITouch, with event: UIEvent?, isTracking: Bool) {
        guard let targetViews = view.findActionRepresentationViews() else {
            resetRepresentationView()
            return
        }
        guard let touched = targetViews.first(where: { view in
            let point = touch.location(in: view)
            return view.point(inside: point, with: event)
        }) else {
            resetRepresentationView()
            return
        }
        activeRepresentationView = touched
        for view in targetViews where view !== touched && view.isHighlighted {
            view.isHighlighted = false
        }
        if !touched.isHighlighted {
            touched.isHighlighted = true
            if isTracking {
                feedback.selectionChanged()
            }
        }
    }

    /// Resets the active representation view and clears its highlighted state.
    ///
    /// This method is called to clean up touch state when touches end or are cancelled.
    private func resetRepresentationView() {
        if let activeRepresentationView, activeRepresentationView.isHighlighted {
            activeRepresentationView.isHighlighted = false
        }
        activeRepresentationView = nil
    }
}

extension UIView {

    /// Finds all action representation views within the view hierarchy.
    ///
    /// This method searches for views that conform to both `UIControl` and `RepresentationMark`
    /// protocols, which are used for interactive elements within alerts.
    ///
    /// - Returns: An array of views that conform to the required protocols, or `nil` if none are found.
    func findActionRepresentationViews() -> [any UIControl & RepresentationMark]? {
        findSubviews(ofType: (any UIControl & RepresentationMark).self)
    }

    /// Recursively finds all subviews of the specified type within the view hierarchy.
    ///
    /// This method performs a depth-first search through the view hierarchy to find
    /// all subviews that match the specified type. It searches both direct subviews
    /// and their descendants.
    ///
    /// - Parameter ofType: The type of views to search for.
    /// - Returns: An array of views of the specified type, or `nil` if none are found.
    func findSubviews<T>(ofType: T.Type) -> [T]? {
        guard subviews.isEmpty == false else { return nil }
        var allViews = [T]()
        for view in subviews where view is T {
            allViews.append(view as! T)
        }
        if allViews.isEmpty {
            for view in subviews {
                if let buttons = view.findSubviews(ofType: T.self) {
                    allViews.append(contentsOf: buttons)
                }
            }
        }
        return allViews
    }
}
