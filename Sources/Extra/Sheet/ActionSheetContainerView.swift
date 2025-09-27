//
//  ActionSheetContainerView.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import UIKit

/// An extension that provides container view support for action sheets.
///
/// This extension defines the container view class that serves as the main container
/// for action sheet content, providing a unified interface for layout management.
extension ActionSheet {

    /// A container view that holds the content of an action sheet.
    ///
    /// `ContainerView` serves as the main container for action sheet content,
    /// providing a unified interface for layout management and visual presentation.
    /// It conforms to `AlertContent` to integrate with the alert system.
    class ContainerView: UIView & AlertContent { }
}
