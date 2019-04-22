//
//  CodeChallengeBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/21/19.
//

import Foundation
import SwiftMark

final class CodeChallengeBuilder<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    
    private typealias Block = MarkdownBlock<View, DefinitionStore.Definition>
    private let header: Header<View, DefinitionStore.Definition, Codec>
    private let markdown: Markdown<View, DefinitionStore, Codec>
    
    init(header: Header<View, DefinitionStore.Definition, Codec>, markdown: Markdown<View, DefinitionStore, Codec>) {
        self.header = header
        self.markdown = markdown
    }
    
    func generateCodeChallenge() throws -> CodeChallenge {
        let title = header.text.split(separator: " ").dropFirst(3).joined(separator: " ")
        let cc = CodeChallenge(title: title)
        
        popUntilEndOfStep()
        
        return cc
    }
    
    func popUntilEndOfStep() {
        let _ = markdown.popWhile { block in
            guard let block = block else {
                return .stop
            }
            
            if block.isHeader(ofLevel: 2) {
                return .stop
            }
            
            return .pop
        }
    }
}
