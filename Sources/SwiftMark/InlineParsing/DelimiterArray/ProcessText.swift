//
//  ProcessText.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

fileprivate enum Break {
    case spacesHardbreak
    case backslashHardbreak
    case softbreak
}

struct TextInlineNodeIterator<View, Codec>: IteratorProtocol where View: BidirectionalCollection, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    private let view: View
    private let text: [Range<View.Index>]
    private var i: Int
    
    private var queuedTextInline: TextInlineNode<View>? = nil
    
    init(view: View, text: [Range<View.Index>]) {
        self.view = view
        self.text = text
        self.i = text.startIndex
    }
    
    mutating func next() -> TextInlineNode<View>? {
        if case let q? = queuedTextInline {
            queuedTextInline = nil
            return q
        }
        
        defer { i += 1 }
        guard i < text.endIndex else { return nil }
        
        let indices = text[i]
        guard !indices.isEmpty else { return nil }
        
        let (linebreak, end) = { () -> (Break, View.Index) in
            var numberOfSpaces = 0
            var end = indices.upperBound
            guard end > indices.lowerBound else {
                return (.softbreak, end)
            }
            
            self.view.formIndex(before: &end)
            switch self.view[end] {
            case Codec.space:
                numberOfSpaces += 1
                while end > indices.lowerBound {
                    self.view.formIndex(before: &end)
                    if self.view[end] == Codec.space {
                        numberOfSpaces += 1
                    } else {
                        return (numberOfSpaces < 2 ? .softbreak : .spacesHardbreak, view.index(after: end))
                    }
                }
                
                return (.softbreak, end)
                
            case Codec.backslash:
                return (.backslashHardbreak, end)
                
            default:
                return (.softbreak, view.index(after: end))
            }
        }()
        
        if i == text.endIndex - 1 {
            let adjustedEnd = linebreak == .backslashHardbreak ? view.index(after: end) : end
            return TextInlineNode(kind: .text, start: indices.lowerBound, end: adjustedEnd)
        } else {
            queuedTextInline = TextInlineNode(kind: linebreak == .softbreak ? . softbreak : .hardbreak, start: end, end: indices.upperBound)
            return TextInlineNode(kind: .text, start: indices.lowerBound, end: end)
        }
    }
}
