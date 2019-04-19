//
//  InlineParsing.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

extension NonTextInlineNode {
    /// Returns true iff lhs.start < rhs.start
    static func < (lhs: NonTextInlineNode, rhs: NonTextInlineNode) -> Bool { return lhs.start <  rhs.start }
}

extension MarkdownParser {
    func parseInlines(_ text: [Range<View.Index>]) -> Tree<Inline> {
        var nonTextDelimiters = delimiters(in: text)
        var nodes: [NonTextInline] = []
        
        processAllMonospacedText(&nonTextDelimiters, appendingTo: &nodes)
        processAllReferences(&nonTextDelimiters, appendingTo: &nodes)
        processAllEmphases(&nonTextDelimiters, indices: nonTextDelimiters.indices, appendingTo: &nodes)
        processAllEscapingBackslashes(nonTextDelimiters, appendingTo: &nodes)
        
        nodes.sort(by: <)
        
        let textNodes = TextInlineNodeIterator<View, Codec>(view: view, text: text)
        return makeAST(text: textNodes, nonText: nodes)
    }
    
    private func delimiters(in text: [Range<View.Index>]) -> [Delimiter?] {
        var delimiters: [Delimiter?] = []
        
        var scanner = Scanner(data: view)
        
        for line in text {
            scanner.startIndex = line.lowerBound
            scanner.endIndex = line.upperBound
            
            var prevTokenKind = TokenKind.whitespace
            
            while case let token? = scanner.pop() {
                let currentTokenKind = MarkdownParser.tokenKind(token)
                defer { prevTokenKind = currentTokenKind }
                
                guard case .punctuation = currentTokenKind else {
                    continue
                }
                
                switch token {
                case Codec.underscore, Codec.asterisk:
                    let indexBeforeRun = view.index(before: scanner.startIndex)
                    scanner.popWhile(token)
                    let nextTokenKind = scanner.peek().flatMap(MarkdownParser.tokenKind) ?? .whitespace
                    
                    let delimiterState = DelimiterState(token: token, prev: prevTokenKind, next: nextTokenKind, codec: Codec.self)
                    let level = view.distance(from: indexBeforeRun, to: scanner.startIndex)
                    let kind: EmphasisKind = token == Codec.underscore ? .underscore : .asterisk
                    delimiters.append((scanner.startIndex, .emphasis(kind, delimiterState, numericCast(level))))
                    
                case Codec.backtick:
                    let indexBeforeRun = view.index(before: scanner.startIndex)
                    scanner.popWhile(Codec.backtick)
                    let level = view.distance(from: indexBeforeRun, to: scanner.startIndex)
                    delimiters.append((scanner.startIndex, .code(numericCast(level))))
                    
                case Codec.exclammark:
                    if scanner.pop(Codec.leftsqbck) {
                        delimiters.append((scanner.startIndex, .unwrappedReferenceOpener))
                    }
                    
                case Codec.leftsqbck:
                    delimiters.append((scanner.startIndex, .referenceOpener))
                    
                case Codec.rightsqbck:
                    delimiters.append((scanner.startIndex, .referenceCloser))
                    if scanner.pop(Codec.leftparen) {
                        delimiters.append((scanner.startIndex, .referenceValueOpener))
                    }
                    
                case Codec.leftparen:
                    delimiters.append((scanner.startIndex, .leftParen))
                    
                case Codec.rightparen:
                    delimiters.append((scanner.startIndex, .rightParen))
                    
                case Codec.backslash:
                    guard case let el? = scanner.peek() else {
                        break
                    }
                    if Codec.isPunctuation(el) {
                        delimiters.append((scanner.startIndex, .escapingBackslash))
                        if el != Codec.backtick { _ = scanner.pop() }
                    }
                    
                default:
                    break
                }
            }
        }
        
        return delimiters
    }
}
