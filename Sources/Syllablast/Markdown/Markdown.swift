//
//  Markdown.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

enum MarkdownError: Error {
    case expectedBlock
    case expectedFrontmatter
    case expectedHeader
    case expectedFence
    case expectedReferenceDefinition
}

public final class Markdown<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    typealias Block = MarkdownBlock<View, DefinitionStore.Definition>
    var source: View
    var codec: Codec.Type
    private var ast: Queue<Block>
    
    public init(source: View, definitionStore: DefinitionStore, codec: Codec.Type) {
        self.source = source
        self.codec = codec
        let doc = parsedMarkdown(source: source, definitionStore: definitionStore, codec: codec.self)
        var queue = Queue<Block>()
        
        for node in doc {
            queue.enqueue(node)
        }
        
        self.ast = queue
    }
    
    var isAtEnd: Bool {
        return ast.isEmpty
    }
    
    func popWhile(_ predicate: (Block?) throws -> PopOrStop) rethrows -> Queue<Block> {
        return try ast.dequeueWhile(predicate)
    }
    
    func frontmatter() throws -> Frontmatter<View, DefinitionStore, Codec> {
        guard let firstNode = ast.peek(), firstNode.isThematicBreak, let closingDelimiter = ast.peek(by: 2), closingDelimiter.isThematicBreak else {
            throw MarkdownError.expectedFrontmatter
        }
        
        ast.dequeue() // first thematic break
        guard let block = ast.dequeue(), let paragraphBlock = block.paragraphBlock else { fatalError("Node has to be a paragraph node") }
        
        ast.dequeue() // second thematic break
        
        return try Frontmatter(block: paragraphBlock, source: source, codec: codec.self)
    }
    
    /// Returns a Header object iff the next block in the ast is a HeaderBlock
    func header() throws -> Header<View, DefinitionStore.Definition, Codec> {
        guard let firstNode = ast.peek(), firstNode.isHeaderBlock else {
            throw MarkdownError.expectedHeader
        }
        
        guard let block = ast.dequeue(), let headerBlock = block.headerBlock else {
            fatalError("Block must be a header block")
        }
        
        return try Header(block: headerBlock, source: source, codec: codec.self)
    }
    
    func fence() throws -> Fence<View, Codec> {
        guard let nextNode = ast.peek(), nextNode.isFenceBlock else {
            throw MarkdownError.expectedFence
        }
        
        guard let block = ast.dequeue(), let fenceBlock = block.fenceBlock else {
            fatalError("Block must be a fence block")
        }
        
        return Fence(block: fenceBlock, source: source, codec: codec.self)
    }
    
    func peek() -> Block? {
        return ast.peek()
    }
    
    func next() -> Block? {
        return ast.dequeue()
    }
}

extension Markdown: CustomStringConvertible {
    public var description: String {
        return ast.description
    }
}
