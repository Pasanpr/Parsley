//
//  BlockAST.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

enum BlockNode<View, RefDef> where View: BidirectionalCollection, RefDef: ReferenceDefinitionProtocol {
    case paragraph(ParagraphNode<View>)
    case header(HeaderNode<View>)
    case quote(QuoteNode<View>)
    case listItem(ListItemNode<View>)
    case list(ListNode<View>)
    case fence(FenceNode<View>)
    case code(CodeNode<View>)
    case thematicBreak(ThematicBreakNode<View>)
    case referenceDefinition(ReferenceDefinitionNode<View, RefDef>)
}

final class ParagraphNode<View> where View: BidirectionalCollection {
    var text: [Range<View.Index>]
    var closed: Bool
    
    init(text: [Range<View.Index>]) {
        self.text = text
        self.closed = false
    }
}

final class HeaderNode<View> where View: BidirectionalCollection {
    let markers: (Range<View.Index>, Range<View.Index>?)
    let text: Range<View.Index>
    let level: Int32
    
    init(markers: (Range<View.Index>, Range<View.Index>?), text: Range<View.Index>, level: Int32) {
        self.markers = markers
        self.text = text
        self.level = level
    }
}

final class QuoteNode<View> where View: BidirectionalCollection {
    var markers: [View.Index]
    var closed: Bool
    
    init(firstMarker: View.Index) {
        self.markers = [firstMarker]
        self.closed = false
    }
}

final class ListItemNode<View> where View: BidirectionalCollection {
    let markerSpan: Range<View.Index>
    
    init(markerSpan: Range<View.Index>) {
        self.markerSpan = markerSpan
    }
}

final class ListNode<View> where View: BidirectionalCollection {
    let kind: ListKind
    var state: ListState
    var minimumIndent: Int
    
    init(kind: ListKind, state: ListState) {
        self.kind = kind
        self.state = state
        self.minimumIndent = 0
    }
}

final class CodeNode<View> where View: BidirectionalCollection {
    var text: [Range<View.Index>]
    var trailingEmptyLines: [Range<View.Index>]
    
    init(text: [Range<View.Index>], trailingEmptyLines: [Range<View.Index>]) {
        self.text = text
        self.trailingEmptyLines = trailingEmptyLines
    }
}

final class FenceNode<View> where View: BidirectionalCollection {
    typealias Indices = Range<View.Index>
    
    let kind: FenceKind
    var markers: (Indices, Indices?)
    let name: Indices
    var text: [Indices]
    let level: Int32
    let indent: Int
    var closed: Bool
    
    init(kind: FenceKind, startMarker: Indices, name: Indices, text: [Indices], level: Int32, indent: Int) {
        self.kind = kind
        self.markers = (startMarker, nil)
        self.name = name
        self.text = text
        self.level = level
        self.indent = indent
        self.closed = false
    }
}

final class ThematicBreakNode<View> where View: BidirectionalCollection {
    let span: Range<View.Index>
    
    init(span: Range<View.Index>) {
        self.span = span
    }
}

final class ReferenceDefinitionNode<View, RefDef> where View: BidirectionalCollection, RefDef: ReferenceDefinitionProtocol {
    let title: Range<View.Index>
    let definition: Range<View.Index>
    
    init(title: Range<View.Index>, definition: Range<View.Index>) {
        self.title = title
        self.definition = definition
    }
}
