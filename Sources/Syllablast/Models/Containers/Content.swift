//
//  Content.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

protocol Content: class {
    var title: String { get }
    var topic: Topic { get }
}
