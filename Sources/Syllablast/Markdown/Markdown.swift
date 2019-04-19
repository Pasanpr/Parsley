//
//  Markdown.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

public final class Markdown<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    public typealias Block = MarkdownBlock<View, DefinitionStore.Definition>
    private var ast: Queue<Block>
    
    public init(source: View, definitionStore: DefinitionStore, codec: Codec.Type) {
        let doc = parsedMarkdown(source: source, definitionStore: definitionStore, codec: codec.self)
        var queue = Queue<Block>()
        
        for node in doc {
            queue.enqueue(node)
        }
        
        self.ast = queue
    }
    
    func frontmatter(source: View, codec: Codec.Type) throws -> Frontmatter<View, DefinitionStore, Codec> {
        guard let firstNode = ast.peek(), firstNode.isThematicBreak, let closingDelimiter = ast.peek(by: 2), closingDelimiter.isThematicBreak else {
            throw FrontmatterError.missingFrontmatter
        }
        
        ast.dequeue() // first thematic break
        guard let block = ast.dequeue(), let paragraphBlock = block.paragraphBlock else { fatalError("Node has to be a paragraph node") }
        
        ast.dequeue() // second thematic break
        
        return try Frontmatter(block: paragraphBlock, source: source, codec: codec.self)
    }
    
    var next: Block? {
        return ast.dequeue()
    }
    
    var isAtEnd: Bool {
        return ast.isEmpty
    }
}
