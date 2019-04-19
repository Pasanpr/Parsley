//
//  ReferenceDefinition.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

public protocol ReferenceDefinitionProtocol {
    init(string: String)
}

extension String: ReferenceDefinitionProtocol {
    public init(string: String) { self = string }
}

public protocol ReferenceDefinitionStore {
    associatedtype Definition: ReferenceDefinitionProtocol
    
    mutating func add(key: String, value: String)
    func definition(for key: String) -> Definition?
}

public struct DefaultReferenceDefinitionStore: ReferenceDefinitionStore {
    public typealias Definition = String
    
    private var dict: [String: String] = [:]
    
    public init() {}
    
    public mutating func add(key: String, value: String) {
        let lowercasedKey = key.lowercased()
        if dict[lowercasedKey] == nil {
            dict[lowercasedKey] = value
        }
    }
    
    public func definition(for key: String) -> String? {
        return dict[key.lowercased()]
    }
}

public struct ParagraphBlock<View, RefDef> where View: BidirectionalCollection {
    public let text: [MarkdownInline<View, RefDef>]
}

public struct HeaderBlock <View, RefDef> where View: BidirectionalCollection {
    public let level: Int
    public let text: [MarkdownInline<View, RefDef>]
    public let markers: (Range<View.Index>, Range<View.Index>?)
}

public struct QuoteBlock<View, RefDef> where View: BidirectionalCollection {
    public let content: [MarkdownBlock<View, RefDef>]
    public let markers: [View.Index]
}

public struct CodeBlock<View> where View: BidirectionalCollection {
    public let text: [Range<View.Index>]
}

public struct FenceBlock <View: BidirectionalCollection> {
    public let name: Range<View.Index>
    public let text: [Range<View.Index>]
    public let markers: (Range<View.Index>, Range<View.Index>?)
}

public enum ListBlockKind {
    
    case unordered
    case ordered(startingAt: Int)
    
    init(kind: ListKind) {
        switch kind {
        case .bullet(_): self = .unordered
        case .number(_, let n): self = .ordered(startingAt: n)
        }
    }
}

public struct ListItemBlock <View: BidirectionalCollection, RefDef> {
    public let marker: Range<View.Index>
    public let content: [MarkdownBlock<View, RefDef>]
}

public struct ListBlock <View: BidirectionalCollection, RefDef> {
    public let kind: ListBlockKind
    public let items: [ListItemBlock<View, RefDef>]
}

public struct ReferenceDefinitionBlock <View: BidirectionalCollection, RefDef> {
    public let key: Range<View.Index>
    public let definition: Range<View.Index>
}

public struct ThematicBreakBlock<View> where View: BidirectionalCollection {
    public let marker: Range<View.Index>
}

public struct TextInline<View> where View: BidirectionalCollection {
    public let span: Range<View.Index>
}

public struct BreakInline<View> where View: BidirectionalCollection {
    public let span: Range<View.Index>
}

public struct ReferenceInline<View: BidirectionalCollection, RefDef> {
    public let kind: ReferenceKind
    public let title: [MarkdownInline<View, RefDef>]
    public let definition: RefDef
    public let markers: [Range<View.Index>]
}

public struct EmphasisInline <View, RefDef> where View: BidirectionalCollection {
    public let level: Int
    public let content: [MarkdownInline<View, RefDef>]
    public let markers: (Range<View.Index>, Range<View.Index>)
}

public struct MonospacedTextInline <View: BidirectionalCollection, RefDef> {
    public let content: [MarkdownInline<View, RefDef>]
    public let markers: (Range<View.Index>, Range<View.Index>)
}

public struct EscapingBackslashInline <View: BidirectionalCollection> {
    public let index: View.Index
}

public indirect enum MarkdownInline<View, RefDef> where View: BidirectionalCollection {
    case text(TextInline<View>)
    case reference(ReferenceInline<View, RefDef>)
    case softbreak(BreakInline<View>)
    case hardbreak(BreakInline<View>)
    case emphasis(EmphasisInline<View, RefDef>)
    case monospacedText(MonospacedTextInline<View, RefDef>)
    case escapingBackslash(EscapingBackslashInline<View>)
}

public indirect enum MarkdownBlock<View, RefDef> where View: BidirectionalCollection {
    case paragraph(ParagraphBlock<View, RefDef>)
    case header(HeaderBlock<View, RefDef>)
    case quote(QuoteBlock<View, RefDef>)
    case code(CodeBlock<View>)
    case fence(FenceBlock<View>)
    case thematicBreak(ThematicBreakBlock<View>)
    case list(ListBlock<View, RefDef>)
    case referenceDefinition(ReferenceDefinitionBlock<View, RefDef>)
}
