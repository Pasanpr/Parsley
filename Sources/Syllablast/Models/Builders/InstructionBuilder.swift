//
//  InstructionBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/20/19.
//

import Foundation
import SwiftMark

final class InstructionBuilder<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    private typealias Block = MarkdownBlock<View, DefinitionStore.Definition>
    private let header: Header<View, DefinitionStore.Definition, Codec>
    private let markdown: Markdown<View, DefinitionStore, Codec>
    
    init(header: Header<View, DefinitionStore.Definition, Codec>, markdown: Markdown<View, DefinitionStore, Codec>) {
        self.header = header
        self.markdown = markdown
    }
    
    func generateInstruction(withTopic topic: Topic) throws -> Instruction<View, DefinitionStore.Definition> {
        let title = header.text.split(separator: " ").dropFirst(2).joined(separator: " ")
        let metadata = try readInstructionMetadata()
        
        if metadata.format == .markdown {
            let instructionMarkdown = try readMarkdown()
            let instruction = Instruction(title: title, description: metadata.description, markdown: instructionMarkdown, accessLevel: metadata.accessLevel, estimatedMinutes: metadata.estimatedMinutes, topic: topic)
            
            if !isAtEndOfStep() {
                instruction.learningObjectives = try generateLearningObjectives(withParent: instruction)
            }
            
            return instruction
        } else {
            // Video Based Instruction steps not implemented
            fatalError()
        }
    }
    
    private func readInstructionMetadata() throws -> InstructionMetadata<View, Codec> {
        let instructionFence = try markdown.fence()
        
        guard instructionFence.isYamlBlock else {
            throw MarkdownError.expectedFence
        }
        
        let metadata: InstructionMetadata<View, Codec> = try InstructionMetadata.instructionMetadataFromYaml(instructionFence.body)
        return metadata
    }
    
    private func readMarkdown() throws -> Queue<Block> {
        let queue = try markdown.popWhile { block in
            guard let block = block else {
                throw MarkdownError.expectedBlock
            }
            
            if block.isThematicBreak {
                return .stop
            } else if block.isHeader(ofLevel: 2) {
                // Next Step
                return .stop
            } else {
                return .pop
            }
        }
        
        return queue
    }
    
    private func generateLearningObjectives(withParent parent: Content) throws -> [LearningObjective] {
        return try LearningObjectiveBuilder(markdown: markdown, parent: parent).generateLearningObjectives()
    }
    
    private func isAtEndOfStep() -> Bool {
        guard let next = markdown.peek(), next.isHeader(ofLevel: 2) else {
            return false
        }
        
        return true
    }
}
