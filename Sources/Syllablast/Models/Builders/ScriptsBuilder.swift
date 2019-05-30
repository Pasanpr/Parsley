//
//  ScriptsBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/20/19.
//

import Foundation
import SwiftMark

final class ScriptsBuilder<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    
    private typealias Block = MarkdownBlock<View, DefinitionStore.Definition>
    private let markdown: Markdown<View, DefinitionStore, Codec>
    
    init(markdown: Markdown<View, DefinitionStore, Codec>) {
        self.markdown = markdown
    }
    
    func generateScripts() throws -> Script<View, DefinitionStore.Definition> {
        var sections: [Section<View, DefinitionStore.Definition>] = []
        
        while true {
            if let next = markdown.peek(), next.isThematicBreak || next.isHeader(ofLevel: 2) {
                break
            }
            
            let mode = try readRecordingMode()
            let content = try readContents()
            let section = Section(mode: mode, content: content)
            sections.append(section)
        }
        
        return Script(sections: sections)
    }
    
    private func readRecordingMode() throws -> RecordingMode {
        let modeTitle = try markdown.header()
        guard let mode = RecordingMode(rawValue: modeTitle.text) else {
            throw SyllablastError.missingRecordingMode
        }
        
        return mode
    }
    
    private func readContents() throws -> Queue<Block> {
        return try popUntilNextReadingModeOrEnd()
    }
    
    private func popUntilNextReadingModeOrEnd() throws -> Queue<Block> {
        let queue = try markdown.popWhile { block in
            guard let block = block else {
                throw MarkdownError.expectedBlock
            }
            
            if block.isThematicBreak {
                return .stop
            } else if block.isHeader(ofLevel: 3) {
                // Next Section
                return .stop
            } else if block.isHeader(ofLevel: 2) {
                // Next step
                return .stop
            } else {
                return .pop
            }
        }
        
        return queue
    }
}
