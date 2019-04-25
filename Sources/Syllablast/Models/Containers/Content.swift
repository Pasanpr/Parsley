//
//  Content.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

protocol Content: class {
    var type: ContentType { get }
    var title: String { get }
    var topic: Topic { get }
}

enum ContentType {
    case video
    case instruction
}
