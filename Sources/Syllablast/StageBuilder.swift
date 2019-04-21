//
//  StageBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

enum StageBuilderError: Error {
    case invalidStageHeader
    case invalidStageMetadata
    case invalidStepTitle
}

final class StageBuilder<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    private var markdown: Markdown<View, DefinitionStore, Codec>
    private let topic: Topic
    
    init(markdown: Markdown<View, DefinitionStore, Codec>, topic: Topic) {
        self.markdown = markdown
        self.topic = topic
    }
    
    func generateStage() throws -> Stage<View, DefinitionStore.Definition, Codec> {
        let title = try stageTitle()
        let metadata = try readStageMetadata()
        let steps = try parseSteps()
        let stage =  Stage<View, DefinitionStore.Definition, Codec>(title: title, metadata: metadata)
        stage.steps = steps
        
        return stage
    }
    
    private func stageTitle() throws -> String {
        let header = try markdown.header()
        let strippedTitle = header.text.split(separator: " ").dropFirst(2).joined(separator: " ")
        return strippedTitle
    }
    
    private func readStageMetadata() throws -> StageMetadata<View, DefinitionStore.Definition, Codec> {
        let headerFence = try markdown.fence()
        guard headerFence.isYamlBlock else {
            throw StageBuilderError.invalidStageMetadata
        }
        
        return try StageMetadata.stageMetadataFromYaml(headerFence.body)
    }
    
    private func parseSteps() throws -> [Step<View, DefinitionStore.Definition>] {
        var steps: [Step<View, DefinitionStore.Definition>] = []
        steps.append(try parseStep())
        return steps
    }
    
    private func parseStep() throws -> Step<View, DefinitionStore.Definition> {
        let header = try markdown.header()
        let components = header.text.split(separator: " ")
        
        guard let first = components.first, let stepType = StepType(rawValue: String(first)) else {
            throw StageBuilderError.invalidStepTitle
        }
        
        switch stepType {
        case .video:
            let videoBuilder = VideoBuilder(header: header, markdown: markdown)
            let video = try videoBuilder.generateVideo(withTopic: topic)
            return Step.video(video)
        default:
            fatalError()
        }
    }
}
