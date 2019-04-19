//
//  ProcessEscapingBackslashes.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

extension MarkdownParser {
    /// Append the escaping backslashes contained in `delimiters` to `nodes`
    func processAllEscapingBackslashes(_ delimiters: [Delimiter?], appendingTo nodes: inout [NonTextInline]) {
        for case (let idx, .escapingBackslash)? in delimiters {
            nodes.append(.init(
                kind: .escapingBackslash,
                start: view.index(before: idx),
                end: idx
                ))
        }
    }
}
