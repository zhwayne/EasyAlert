//
//  TitleAndMessage.swift
//  EasyAlert
//
//  Created by iya on 2022/12/7.
//

import Foundation

public protocol Title { }
public protocol Message { }

extension String: Title, Message { }
extension NSAttributedString: Title, Message { }

@available(iOS 15.0, *)
extension AttributedString: Title, Message { }
