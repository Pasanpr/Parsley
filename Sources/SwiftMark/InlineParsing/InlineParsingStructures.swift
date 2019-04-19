//
//  InlineParsingStructures.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

enum EmphasisKind {
    case asterisk, underscore
}

enum DelimiterKind {
    case emphasis(EmphasisKind, DelimiterState, Int32) // run of * or _
    case code(Int32) // run of `
    case referenceOpener // [
    case unwrappedReferenceOpener // ![
    case referenceCloser // ]
    
    
    case referenceValueOpener // ( after a ]
    case leftParen // ( used to allow pair of brackets in direct reference value definition. e.g. [link]((here))
    case rightParen         // ) used to close a direct reference value definition
    
    case escapingBackslash  // \ followed by punctuation
}

private func leftFlanking(prev: TokenKind, next: TokenKind) -> Bool {
    return next != .whitespace && (next != .punctuation || prev != .neither)
}

private func rightFlanking(prev: TokenKind, next: TokenKind) -> Bool {
    return leftFlanking(prev: next, next: prev)
}

struct DelimiterState: OptionSet {
    let rawValue: UInt8
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    static let closing = DelimiterState(rawValue: 0b01)
    static let opening = DelimiterState(rawValue: 0b10)
    
    init<Codec>(token: Codec.CodeUnit, prev: TokenKind, next: TokenKind, codec: Codec.Type) where Codec: MarkdownParserCodec {
        var state: DelimiterState = []
        let isLeftFlanking = leftFlanking(prev: prev, next: next)
        let isRightFlanking = rightFlanking(prev: prev, next: next)
        
        switch token {
        case Codec.asterisk:
            if isRightFlanking { state.formUnion(.closing) }
            if isLeftFlanking { state.formUnion(.opening) }
            
        case Codec.underscore:
            if isRightFlanking && (!isLeftFlanking  || prev == .punctuation) { state.formUnion(.closing) }
            if isLeftFlanking  && (!isRightFlanking || next == .punctuation) { state.formUnion(.opening) }
            
        default:
            fatalError()
            
        }
        
        self = state
    }
}

enum TokenKind {
    case whitespace, punctuation, neither
}

extension MarkdownParser {
    static func tokenKind(_ token: Codec.CodeUnit) -> TokenKind {
        switch token {
        case Codec.space, Codec.linefeed:
            return .whitespace
        case let t where Codec.isPunctuation(t):
            return .punctuation
        default:
            return .neither
        }
    }
}
