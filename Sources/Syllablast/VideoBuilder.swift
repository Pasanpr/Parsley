//
//  VideoBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

enum VideoBuilderError: Error {
    case expectedFence
}

final class VideoBuilder<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    private typealias Block = MarkdownBlock<View, DefinitionStore.Definition>
    private let header: Header<View, DefinitionStore.Definition, Codec>
    private let markdown: Markdown<View, DefinitionStore, Codec>
    
    
    init(header: Header<View, DefinitionStore.Definition, Codec>, markdown: Markdown<View, DefinitionStore, Codec>) {
        self.header = header
        self.markdown = markdown
    }
    
    func generateVideo(withTopic topic: Topic) throws -> Video<View, DefinitionStore.Definition> {
        let title = header.text.split(separator: " ").dropFirst(2).joined(separator: " ")
        let metadata = try readVideoMetadata()
        let script = try generateScripts()
        let notes = try generateNotes()
        
        let video = Video(title: title, description: metadata.description, accessLevel: metadata.accessLevel, published: metadata.published, scripts: script, notes: notes, authors: metadata.authors, topic: topic)
        
        let learningObjectives = try generateLearningObjectives(withParent: video)
        video.addLearningObjectives(learningObjectives)
        
        return video
    }
    
    private func readVideoMetadata() throws -> VideoMetadata<View, Codec> {
        let videoFence = try markdown.fence()
        
        guard videoFence.isYamlBlock else {
            throw VideoBuilderError.expectedFence
        }
        
        let metadata: VideoMetadata<View, Codec> = try VideoMetadata.videoMetadataFromYaml(videoFence.body)
        return metadata
    }
    
    private func generateScripts() throws -> Script<View, DefinitionStore.Definition> {
        return try ScriptsBuilder(markdown: self.markdown).generateScripts()
    }
    
    private func generateLearningObjectives(withParent parent: Content) throws -> [LearningObjective] {
        return try LearningObjectiveBuilder(markdown: markdown, parent: parent).generateLearningObjectives()
    }
    
    private func generateNotes() throws -> Notes {
        return Notes()
    }
}
