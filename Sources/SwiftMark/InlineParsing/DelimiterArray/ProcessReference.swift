//
//  ProcessReference.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

extension MarkdownParser {
    
    /// Parse the references contained in `delimiters`, along with the inline nodes they contain, and append them to `nodes`
    func processAllReferences(_ delimiters: inout [Delimiter?], appendingTo nodes: inout [NonTextInline]) {
        var start = delimiters.startIndex
        while let newStart = processReference(&delimiters, indices: start ..< delimiters.endIndex, appendingTo: &nodes) {
            start = newStart
        }
    }
    
    private func processReference(_ delimiters: inout [Delimiter?], indices: CountableRange<Int>, appendingTo nodes: inout [NonTextInline]) -> Int? {
        
        guard let (newStart, openingTitleDelIdx, openingTitleDel, closingTitleDelIdx, closingTitleDel, refKind) = {
            () -> (Int, Int, Delimiter, Int, Delimiter, ReferenceKind)? in
            
            var firstOpeningReferenceIdx: Int? = nil
            var opener: (index: Int, del: Delimiter, kind: ReferenceKind)?
            
            for i in indices {
                guard case let del? = delimiters[i] else { continue }
                
                switch del.kind {
                case .referenceCloser:
                    if case let o? = opener {
                        return (firstOpeningReferenceIdx!, o.index, o.del, i, del, o.kind)
                    }
                    
                case .referenceOpener:
                    if firstOpeningReferenceIdx == nil { firstOpeningReferenceIdx = i }
                    opener = (i, del, .normal)
                    
                case .unwrappedReferenceOpener:
                    if firstOpeningReferenceIdx == nil { firstOpeningReferenceIdx = i }
                    opener = (i, del, .unwrapped)
                    
                default:
                    continue
                }
            }
            return nil
            }()
            else {
                return nil
        }
        
        delimiters[openingTitleDelIdx] = nil
        delimiters[closingTitleDelIdx] = nil
        
        guard let (definition, span, spanEndDelIdx) = {
            () -> (RefDef, Range<View.Index>, Int)? in
            
            let nextDelIdx = closingTitleDelIdx+1
            let nextDel = nextDelIdx < delimiters.endIndex ? delimiters[nextDelIdx] : nil
            
            switch nextDel?.kind {
                
            case .referenceValueOpener?:
                
                delimiters[nextDelIdx] = nil
                guard let (valueCloserDelIdx, valueCloserDel) = { () -> (Int, Delimiter)? in
                    for i in nextDelIdx ..< indices.upperBound {
                        if case let del? = delimiters[i], case .rightParen = del.kind {
                            return (i, del)
                        }
                    }
                    return nil
                    }() else {
                        return nil
                }
                
                delimiters[valueCloserDelIdx] = nil
                
                let definition = RefDef(string: Codec.string(fromTokens: view[nextDel!.idx ..< view.index(before: valueCloserDel.idx)]))
                let span = { () -> Range<View.Index> in
                    let lowerbound = view.index(openingTitleDel.idx, offsetBy: numericCast(-refKind.textWidth))
                    return lowerbound ..< valueCloserDel.idx
                }()
                
                return (definition, span, valueCloserDelIdx)
                
            case .referenceOpener? where nextDel!.idx == view.index(after: closingTitleDel.idx):
                
                delimiters[nextDelIdx] = nil
                guard let (aliasCloserIdx, aliasCloserDel) = { () -> (Int, Delimiter)? in
                    for i in nextDelIdx ..< indices.upperBound {
                        if case let del? = delimiters[i], case .referenceCloser = del.kind {
                            return (i, del)
                        }
                    }
                    return nil
                    }()
                    else {
                        return nil
                }
                
                let s = Codec.string(fromTokens: view[nextDel!.idx ..< view.index(before: aliasCloserDel.idx)])
                guard case let definition? = definitionStore.definition(for: s) else {
                    var newNextDel = nextDel!
                    newNextDel.kind = .referenceOpener
                    delimiters[nextDelIdx] = newNextDel
                    return nil
                }
                
                delimiters[openingTitleDelIdx] = nil
                delimiters[aliasCloserIdx] = nil
                
                let width = refKind == .unwrapped ? 2 : 1
                let span = view.index(openingTitleDel.idx, offsetBy: numericCast(-width)) ..< aliasCloserDel.idx
                
                return (definition, span, aliasCloserIdx)
                
            default:
                let s = Codec.string(fromTokens: view[openingTitleDel.idx ..< view.index(before: closingTitleDel.idx)])
                guard case let definition? = definitionStore.definition(for: s) else {
                    return nil
                }
                delimiters[openingTitleDelIdx] = nil
                let width = refKind == .unwrapped ? 2 : 1
                let span = view.index(openingTitleDel.idx, offsetBy: numericCast(-width)) ..< closingTitleDel.idx
                
                return (definition, span, closingTitleDelIdx)
            }
            }()
            else {
                return newStart
        }
        
        let title = openingTitleDel.idx ..< view.index(before: closingTitleDel.idx)
        
        let refNode = NonTextInline(
            kind: .reference(refKind, title: title, definition: definition),
            start: span.lowerBound,
            end: span.upperBound)
        
        let delimiterRangeForTitle: CountableRange<Int> = (openingTitleDelIdx + 1) ..< closingTitleDelIdx
        processAllEmphases(&delimiters, indices: delimiterRangeForTitle, appendingTo: &nodes)
        
        let delimiterRangeForSpan = openingTitleDelIdx ... spanEndDelIdx
        
        for i in delimiterRangeForTitle {
            guard case let del? = delimiters[i] else { continue }
            switch del.kind {
            case .escapingBackslash: continue
            default: delimiters[i] = nil
            }
        }
        for i in delimiterRangeForTitle.upperBound ..< delimiterRangeForSpan.upperBound {
            delimiters[i] = nil
        }
        
        nodes.append(refNode)
        return newStart
    }
}

