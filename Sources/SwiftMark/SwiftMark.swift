//
//  SwiftMark.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

public func parsedMarkdown<View, DefinitionStore, Codec>(source: View, definitionStore: DefinitionStore, codec: Codec.Type) -> [MarkdownBlock<View, DefinitionStore.Definition>] where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    return MarkdownParser<View, Codec, DefinitionStore>(view: source, definitionStore: definitionStore).finalAST()
}

extension MarkdownParser {
    func finalAST() -> [MarkdownBlock<View, RefDef>] {
        parseBlocks()
        updateDefinitionStore()
        return blockTree.makeBreadthFirstIterator().compactMap(makeFinalBlock)
    }
    
    fileprivate func makeFinalBlock(from node: Block, children: TreeBreadthFirstIterator<Block>?) -> MarkdownBlock<View, RefDef>? {
        switch node {
            
        case .paragraph(let p):
            let inlines = makeFinalInlineNodeTree(from: parseInlines(p.text).makeBreadthFirstIterator())
            let block = ParagraphBlock(text: inlines)
            return .paragraph(block)
            
        case .header(let h):
            let block = HeaderBlock(
                level: numericCast(h.level),
                text: makeFinalInlineNodeTree(from: parseInlines([h.text]).makeBreadthFirstIterator()),
                markers: h.markers
            )
            return .header(block)
            
        case .quote(let q):
            let block = QuoteBlock(
                content: children?.compactMap(makeFinalBlock) ?? [],
                markers: q.markers
            )
            
            return .quote(block)
            
        case .listItem:
            fatalError()
            
        case let .list(l):
            let items = children?.map { (n, c) -> ListItemBlock<View, RefDef> in
                guard case .listItem(let i) = n else { return .init(marker: view.startIndex ..< view.startIndex, content: []) }
                return ListItemBlock<View, RefDef>(
                    marker: i.markerSpan,
                    content: c?.compactMap(makeFinalBlock) ?? []
                )
                } ?? []
            
            let block = ListBlock(kind: ListBlockKind(kind: l.kind), items: items)
            
            return .list(block)
            
        case .code(let c):
            return .code(CodeBlock(text: c.text))
            
        case .fence(let f):
            let block = FenceBlock<View>(
                name: f.name,
                text: f.text,
                markers: f.markers
            )
            return .fence(block)
            
        case .thematicBreak(let t):
            return .thematicBreak(ThematicBreakBlock(marker: t.span))
            
        case let .referenceDefinition(r):
            return .referenceDefinition(.init(key: r.title, definition: r.definition))
        }
    }
}

// MARK: - Inline Nodes
extension MarkdownParser {
    fileprivate func makeFinalInlineNodeTree(from tree: TreeBreadthFirstIterator<Inline>) -> [MarkdownInline<View, RefDef>] {
        var nodes: [MarkdownInline<View, RefDef>] = []
        
        for (node, children) in tree {
            switch node {
            case .text(let t):
                switch t.kind {
                case .hardbreak:
                    nodes.append(.hardbreak(BreakInline(span: t.start ..< t.end)))
                    
                case .softbreak:
                    nodes.append(.softbreak(BreakInline(span: t.start ..< t.end)))
                    
                case .text:
                    nodes.append(.text(TextInline(span: t.start ..< t.end)))
                }
            case .nonText(let n):
                switch n.kind {
                case .code(let level):
                    let startMarkers = n.start ..< view.index(n.start, offsetBy: numericCast(level))
                    let endMarkers = view.index(n.end, offsetBy: numericCast(-level)) ..< n.end
                    
                    let inline = MonospacedTextInline(
                        content: children.map(makeFinalInlineNodeTree) ?? [],
                        markers: (startMarkers, endMarkers)
                    )
                    nodes.append(.monospacedText(inline))
                    
                case .emphasis(let level):
                    let startMarkers = n.start ..< view.index(n.start, offsetBy: numericCast(level))
                    let endMarkers = view.index(n.end, offsetBy: numericCast(-level)) ..< n.end
                    
                    let inline = EmphasisInline(
                        level: numericCast(level),
                        content: children.map(makeFinalInlineNodeTree) ?? [],
                        markers: (startMarkers, endMarkers)
                    )
                    
                    nodes.append(.emphasis(inline))
                    
                case .reference(let kind, title: let title, definition: let definition):
                    let markers = [n.start ..< title.lowerBound, title.upperBound ..< n.end]
                    
                    let inline = ReferenceInline(
                        kind: kind,
                        title: children.map(makeFinalInlineNodeTree) ?? [],
                        definition: definition,
                        markers: markers
                    )
                    
                    nodes.append(.reference(inline))
                    
                case .escapingBackslash:
                    nodes.append(.escapingBackslash(.init(index: n.start)))
                }
            }
        }
        
        return nodes
    }
}
