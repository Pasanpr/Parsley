//
//  String+Extensions.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/27/19.
//

import Foundation

extension String {
    static func newlines(_ line: Int) -> String {
        return String(repeating: "\n", count: line)
    }
}
