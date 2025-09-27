//
//  BlurEffectView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/13.
//

import UIKit

/// A custom blur effect view that provides advanced blur customization capabilities.
///
/// `BlurEffectView` extends `UIVisualEffectView` to provide fine-grained control over blur effects,
/// including custom blur radius, color tinting, and scaling. This view uses private UIKit APIs
/// to achieve effects that are not available through the standard public APIs.
///
/// **Important:** This class uses private UIKit APIs and may break in future iOS versions.
/// Use with caution and test thoroughly across different iOS versions.
@objcMembers
open class BlurEffectView: UIVisualEffectView {

    /// The underlying custom blur effect that provides the advanced blur capabilities.
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    /// The color tint applied to the blur effect.
    ///
    /// Setting this property applies a color overlay to the blur effect, allowing for
    /// custom colorization of the blurred content. This is useful for creating
    /// themed blur effects that match your app's design.
    open var colorTint: UIColor? {
        get {
            return sourceOver?.value(forKeyPath: "color") as? UIColor
        }
        set {
            prepareForChanges()
            sourceOver?.setValue(newValue, forKeyPath: "color")
            sourceOver?.perform(Selector(("applyRequestedEffectToView:")), with: overlayView)
            applyChanges()
            overlayView?.backgroundColor = newValue
        }
    }

    /// The alpha component of the color tint.
    ///
    /// This property provides a convenient way to adjust the opacity of the color tint
    /// without changing the base color. Values range from 0.0 (fully transparent) to 1.0 (fully opaque).
    open var colorTintAlpha: CGFloat {
        get { return _value(forKey: .colorTintAlpha) ?? 0.0 }
        set { colorTint = colorTint?.withAlphaComponent(newValue) }
    }

    /// The radius of the blur effect in points.
    ///
    /// Higher values create more pronounced blur effects, while lower values create
    /// subtle blur effects. The default value is 0, which means no blur is applied.
    open var blurRadius: CGFloat {
        get {
            return gaussianBlur?.requestedValues?["inputRadius"] as? CGFloat ?? 0
        }
        set {
            prepareForChanges()
            gaussianBlur?.requestedValues?["inputRadius"] = newValue
            applyChanges()
        }
    }

    /// The scale factor applied to the blur effect.
    ///
    /// This property controls the scaling of the blur effect, allowing for fine-tuning
    /// of the visual appearance. The default value is 1.0, which represents normal scaling.
    open var scale: CGFloat {
        get { return _value(forKey: .scale) ?? 1.0 }
        set { _setValue(newValue, forKey: .scale) }
    }

    /// Creates a new blur effect view with the specified effect.
    ///
    /// - Parameter effect: The visual effect to apply. If `nil`, no effect is applied.
    public override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        scale = 1
    }

    /// Creates a new blur effect view from data in the specified coder.
    ///
    /// - Parameter aDecoder: The coder containing the archived data.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scale = 1
    }
}

private extension BlurEffectView {

    /// Returns the value for the specified key from the underlying blur effect.
    ///
    /// This method provides type-safe access to the blur effect's internal properties
    /// using key-value coding. It's used internally to access private blur effect properties.
    ///
    /// - Parameter key: The key to retrieve the value for.
    /// - Returns: The value associated with the key, or `nil` if not found.
    func _value<T>(forKey key: Key) -> T? {
        return blurEffect.value(forKeyPath: key.rawValue) as? T
    }

    /// Sets the value for the specified key on the underlying blur effect.
    ///
    /// This method provides type-safe access to set the blur effect's internal properties
    /// using key-value coding. It's used internally to modify private blur effect properties.
    ///
    /// - Parameters:
    ///   - value: The value to set for the key.
    ///   - key: The key to set the value for.
    func _setValue<T>(_ value: T?, forKey key: Key) {
        blurEffect.setValue(value, forKeyPath: key.rawValue)
    }

    /// Keys used to access the blur effect's internal properties.
    enum Key: String {
        case colorTint, colorTintAlpha, blurRadius, scale
    }
}

extension UIVisualEffectView {
    
    /// The backdrop view that contains the blur effect filters.
    ///
    /// This property accesses the private `_UIVisualEffectBackdropView` that contains
    /// the actual blur effect implementation. This is used internally to modify blur parameters.
    var backdropView: UIView? {
        return subview(of: NSClassFromString("_UIVisualEffectBackdropView"))
    }
    
    /// The overlay view that handles color tinting and other visual effects.
    ///
    /// This property accesses the private `_UIVisualEffectSubview` that handles
    /// color overlays and other visual effects on top of the blur.
    var overlayView: UIView? {
        return subview(of: NSClassFromString("_UIVisualEffectSubview"))
    }
    
    /// The Gaussian blur filter object that controls the blur effect.
    ///
    /// This property provides access to the internal blur filter that can be used
    /// to modify blur parameters such as radius and scale.
    var gaussianBlur: NSObject? {
        return backdropView?.value(forKey: "filters", withFilterType: "gaussianBlur")
    }
    
    /// The source over filter that handles color tinting.
    ///
    /// This property provides access to the internal color overlay filter that
    /// can be used to modify color tinting parameters.
    var sourceOver: NSObject? {
        return overlayView?.value(forKey: "viewEffects", withFilterType: "sourceOver")
    }
    
    /// Prepares the visual effect view for changes by setting up the blur effect.
    ///
    /// This method must be called before modifying blur parameters to ensure
    /// the effect is properly initialized and ready for changes.
    func prepareForChanges() {
        self.effect = UIBlurEffect(style: .light)
        gaussianBlur?.setValue(1.0, forKeyPath: "requestedScaleHint")
    }
    
    /// Applies the pending changes to the visual effect.
    ///
    /// This method must be called after modifying blur parameters to ensure
    /// the changes are actually applied to the visual effect.
    func applyChanges() {
        backdropView?.perform(Selector(("applyRequestedFilterEffects")))
    }
}

extension NSObject {
    
    /// The requested values dictionary for the blur effect filter.
    ///
    /// This property provides access to the internal parameters of blur effect filters,
    /// allowing modification of properties like blur radius and other filter parameters.
    var requestedValues: [String: Any]? {
        get { return value(forKeyPath: "requestedValues") as? [String: Any] }
        set { setValue(newValue, forKeyPath: "requestedValues") }
    }
    
    /// Finds a filter object by its type from a collection of filters.
    ///
    /// This method searches through an array of filter objects to find one that matches
    /// the specified filter type. It's used internally to locate specific blur effect filters.
    ///
    /// - Parameters:
    ///   - key: The key path to the array of filters.
    ///   - filterType: The type of filter to search for.
    /// - Returns: The first filter object that matches the specified type, or `nil` if not found.
    func value(forKey key: String, withFilterType filterType: String) -> NSObject? {
        return (value(forKeyPath: key) as? [NSObject])?.first { $0.value(forKeyPath: "filterType") as? String == filterType }
    }
}

private extension UIView {
    
    /// Finds the first subview of the specified class type.
    ///
    /// This method searches through the view's subviews to find the first one that
    /// matches the specified class type. It's used internally to locate private
    /// UIKit view classes for blur effect manipulation.
    ///
    /// - Parameter classType: The class type to search for.
    /// - Returns: The first subview that matches the class type, or `nil` if not found.
    func subview(of classType: AnyClass?) -> UIView? {
        return subviews.first { type(of: $0) == classType }
    }
}
