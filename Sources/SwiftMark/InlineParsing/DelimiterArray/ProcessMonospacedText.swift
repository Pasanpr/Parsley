//
//  ProcessMonospacedText.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

extension MarkdownParser {
    
    /// Parse the monospaced text nodes contained in `delimiters` and append them to `nodes`
    func processAllMonospacedText(_ delimiters: inout [Delimiter?], appendingTo nodes: inout [NonTextInline]) {
        var start = delimiters.startIndex
        while case let newStart? = processMonospacedText(&delimiters, indices: start ..< delimiters.endIndex, appendingTo: &nodes) {
            start = newStart
        }
    }
    
    /// Parse the first monospaced text node contained in `delimiters[indices]` and append them to `nodes`
    /// - returns: the index of the first backtick delimiter found in `delimiters[indices]`, or `nil` if no monospaced text was found
    func processMonospacedText(_ delimiters: inout [Delimiter?], indices: CountableRange<Int>, appendingTo nodes: inout [NonTextInline]) -> Int? {
        
        guard let (openingDelIdx, openingDel, closingDelIdx, closingDel, level) = {
            () -> (Int, Delimiter, Int, Delimiter, Int32)? in
            
            var escaping: View.Index? = nil
            
            for i in indices {
                
                guard case let del? = delimiters[i] else {
                    escaping = nil
                    continue
                }
                
                switch del.kind {
                case .escapingBackslash:
                    escaping = del.idx
                    
                case .code(let level):
                    defer { escaping = nil }
                    var level = level
                    if case view.index(before: del.idx)? = escaping {
                        level -= 1
                        view.formIndex(after: &delimiters[i]!.idx)
                    }
                    guard level > 0 else {
                        delimiters[i] = nil
                        break
                    }
                    guard let closingDelIdx = { () -> Int? in
                        for j in i+1 ..< indices.upperBound {
                            if case .code(level)? = delimiters[j]?.kind {
                                return j
                            }
                        }
                        return nil
                        }()
                        else {
                            delimiters[i] = nil
                            return nil
                    }
                    return (i, delimiters[i]!, closingDelIdx, delimiters[closingDelIdx]!, level)
                    
                default:
                    escaping = nil
                }
            }
            return nil
            }()
            else {
                return nil
        }
        
        for i in openingDelIdx ... closingDelIdx {
            delimiters[i] = nil
        }
        
        nodes.append(.init(
            kind: .code(level),
            start: view.index(openingDel.idx, offsetBy: numericCast(-level)),
            end: closingDel.idx
            ))
        return closingDelIdx
    }
}

