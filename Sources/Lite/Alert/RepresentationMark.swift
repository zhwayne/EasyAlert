//
//  RepresentationMark.swift
//  EasyAlert
//
//  Created by iya on 2023/1/5.
//

import Foundation

/// A protocol that marks views as representation views for alert interactions.
///
/// `RepresentationMark` is a marker protocol that identifies views that should
/// be treated as interactive elements within alerts. Views that conform to this
/// protocol can be tracked for touch events and provide visual feedback during
/// user interactions.
///
/// This protocol is typically used in conjunction with `UIControl` to create
/// interactive elements that can be highlighted and respond to touch events.
protocol RepresentationMark { }
