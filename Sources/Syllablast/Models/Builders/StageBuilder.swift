//
//  StageBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

extension StringProtocol {
    func whitespaceStripped() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}

enum StageBuilderError: Error {
    case invalidStageHeader
    case invalidStageMetadata(title: String)
    case invalidStepTitle
    case invalidStepMetadata(title: String)
}

final class StageBuilder<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    private var markdown: Markdown<View, DefinitionStore, Codec>
    private let topic: Topic
    private var learningObjectives: Set<LearningObjective> = Set<LearningObjective>()
    
    init(markdown: Markdown<View, DefinitionStore, Codec>, topic: Topic) {
        self.markdown = markdown
        self.topic = topic
    }
    
    func generateStage() throws -> Stage<View, DefinitionStore.Definition, Codec> {
        let title = try stageTitle()
        let metadata = try readStageMetadata(for: title)
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
    
    private func readStageMetadata(for stage: String) throws -> StageMetadata<View, DefinitionStore.Definition, Codec> {
        let headerFence = try markdown.fence()
        guard headerFence.isYamlBlock else {
            throw StageBuilderError.invalidStageMetadata(title: stage)
        }
        
        return try StageMetadata.stageMetadataFromYaml(headerFence.body)
    }
    
    private func parseSteps() throws -> [Step<View, DefinitionStore.Definition>] {
        var steps: [Step<View, DefinitionStore.Definition>] = []
        
        while isWithinStage {
            let step = try parseStep()
            steps.append(step)
        }
        
        return steps
    }
    
    private var isWithinStage: Bool {
        guard let peek = markdown.peek() else {
            return false
        }
        
        if peek.isHeader(ofLevel: 1) {
            return false
        }
        
        return true
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
            
            video.learningObjectives.forEach {
                self.learningObjectives.insert($0)
            }
            
            return Step.video(video)
        case .instruction:
            let instructionBuilder = InstructionBuilder(header: header, markdown: markdown)
            do {
                let instruction = try instructionBuilder.generateInstruction(withTopic: topic)
                
                instruction.learningObjectives.forEach {
                    self.learningObjectives.insert($0)
                }
                
                return Step.instruction(instruction)
            } catch MarkdownError.expectedFence {
                throw StageBuilderError.invalidStepMetadata(title: header.text)
            }
        case .codeChallenge:
            let cc  = try CodeChallengeBuilder(header: header, markdown: markdown).generateCodeChallenge()
            return Step.codeChallenge(cc)
        case .quiz:
            let quiz = try QuizBuilder(header: header, markdown: markdown, learningObjectives: self.learningObjectives).generateQuiz()
            return Step.quiz(quiz)
        }
    }
}
