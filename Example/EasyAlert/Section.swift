//
//  Section.swift
//  EasyAlert_Example
//
//  Created by iya on 2022/5/28.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

enum Section {
    
    case message(title: String?, items: [Item])
    
    case customMessage(title: String?, items: [Item])
    
    enum Item {
        
        case systemAlert(String)
        case messageAlert(String)
        case threeActions(String)
        case allowTapBackground(String)
        case effectBackground(String)
        case leftAlignment(String)
        case cornerRadius(String)
        case attributedTitleAndMessage(String)
    }
}

extension Section {
    
    var items: [Item] {
        switch self {
        case let .message(_, items): return items
        case let .customMessage(_, items):  return items
        }
    }
}
