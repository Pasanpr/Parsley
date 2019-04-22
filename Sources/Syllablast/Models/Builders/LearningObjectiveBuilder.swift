//
//  LearningObjectiveBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/20/19.
//

import Foundation
import SwiftMark

final class LearningObjectiveBuilder<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    
    private typealias Block = MarkdownBlock<View, DefinitionStore.Definition>
    private let markdown: Markdown<View, DefinitionStore, Codec>
    private let parent: Content
    
    init(markdown: Markdown<View, DefinitionStore, Codec>, parent: Content) {
        self.markdown = markdown
        self.parent = parent
    }
    
    func generateLearningObjectives() throws -> [LearningObjective] {
        guard let firstBlock = markdown.next(), firstBlock.isThematicBreak else {
            return []
        }
        
        let queue = popUntilEnd()
        
        return try queue.map { block in
            guard let refDefBlock = block.referenceDefinitionBlock else {
                throw MarkdownError.expectedReferenceDefinition
            }
            
            let referenceDefinition = ReferenceDefintion(block: refDefBlock, source: markdown.source, codec: markdown.codec)
            let learningObjectiveComponents = referenceDefinition.title.split(separator: "-")
            
            guard let delimiter = learningObjectiveComponents.first, delimiter == "LO" else {
                throw SyllablastError.expectedLearningObjective
            }
            
            let componentsWithDelimiterStripped = learningObjectiveComponents.dropFirst()
            
            guard let idString = componentsWithDelimiterStripped.first, let id = Int(String(idString)) else {
                fatalError("Learning Objectives must have IDs")
            }
            
            let componentsWithIdentifierStripped = componentsWithDelimiterStripped.dropFirst()
            
            var cognitiveLevel = CognitiveLevel.recall
            
            if !componentsWithIdentifierStripped.isEmpty, let cognitiveLevelIdString = componentsWithIdentifierStripped.first, let cognitiveLevelId = Int(String(cognitiveLevelIdString)) {
                let parsedCognitiveLevel = CognitiveLevel(id: cognitiveLevelId)
                cognitiveLevel = parsedCognitiveLevel
            }
            
            return LearningObjective(id: id, parent: parent, title: referenceDefinition.definition, cognitiveLevel: cognitiveLevel, topic: parent.topic)
        }
    }
    
    private func popUntilEnd() -> Queue<Block> {
        let queue = markdown.popWhile { block in
            guard let block = block else {
                return .stop
            }
            
            if block.isHeader(ofLevel: 2) {
                return .stop
            } else {
                return .pop
            }
        }
        
        return queue
    }
}

