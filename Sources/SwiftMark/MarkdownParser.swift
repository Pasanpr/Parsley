//
//  MarkdownParser.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

final class MarkdownParser<View: BidirectionalCollection, Codec: MarkdownParserCodec, DefinitionStore: ReferenceDefinitionStore> where View.Element == Codec.CodeUnit {
    let view: View
    var definitionStore: DefinitionStore
    let blockTree: Tree<Block>
    
    init(view: View, definitionStore: DefinitionStore) {
        self.view = view
        self.definitionStore = definitionStore
        self.blockTree = Tree<Block>()
    }
}

extension MarkdownParser {
    typealias Delimiter = (idx: View.Index, kind: DelimiterKind)
    typealias RefDef = DefinitionStore.Definition
    
    typealias Block = BlockNode<View, RefDef>
    typealias Inline = InlineNode<View, RefDef>
    typealias NonTextInline = NonTextInlineNode<View, RefDef>
    
    typealias Line = SwiftMark.Line<View, RefDef>
    typealias LineKind = SwiftMark.LineKind<View, RefDef>
}
