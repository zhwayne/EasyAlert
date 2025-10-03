//
//  ActionPresentationSection.swift
//  EasyAlert
//
//  Created by iya on 2024/5/6.
//

import Foundation

/// Identifies the section of an action presentation that should receive styling tweaks.
///
/// Use this enum to target either the standard action area or the cancel action area when
/// providing custom backgrounds or other section-specific configuration.
public enum ActionPresentationSection {
    /// The section that hosts regular actions.
    case normal

    /// The section that hosts cancel actions.
    case cancel
}
