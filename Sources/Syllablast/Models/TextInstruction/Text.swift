//
//  Text.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

final class Instruction<View, DefinitionStore>: Content, Encodable where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol {
    typealias Block = MarkdownBlock<View, DefinitionStore>
    
    let title: String
    let description: String
    let format: InstructionFormat
    let markdown: Queue<Block>
    let videoTitle: String?
    let videoDescription: String?
    let videoAuthors: [Author]
    let accessLevel: AccessLevel
    let published: Bool
    let estimatedMinutes: Int
    var learningObjectives: [LearningObjective]
    let topic: Topic
    
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case description
        case format
        case markdown
        case accessLevel = "access_level"
        case published
        case estimatedMinutes = "estimated_minutes"
        case learningObjectives = "learning_objectives"
        
        // Video Based
        
        case videoTitle = "video_title"
        case videoDescription = "video_description"
        case videoAuthors = "video_authors"
    }
    
    init(title: String, description: String, markdown: Queue<Block>, accessLevel: AccessLevel, estimatedMinutes: Int, topic: Topic) {
        self.title = title
        self.description = description
        self.format = .markdown
        self.markdown = markdown
        self.learningObjectives = []
        self.published = false
        self.estimatedMinutes = estimatedMinutes
        self.videoTitle = nil
        self.videoDescription = nil
        self.videoAuthors = []
        self.accessLevel = accessLevel
        self.topic = topic
    }
    
    init(title: String, description: String, videoTitle: String, videoDescription: String, videoAuthors: [Author], accessLevel: AccessLevel, estimatedMinutes: Int, topic: Topic) {
        self.title = title
        self.description = description
        self.format = .video
        self.markdown = Queue<Block>()
        self.learningObjectives = []
        self.published = false
        self.estimatedMinutes = estimatedMinutes
        self.videoTitle = videoTitle
        self.videoDescription = videoDescription
        self.videoAuthors = videoAuthors
        self.accessLevel = accessLevel
        self.topic = topic
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("Instruction", forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(format, forKey: .format)
        
        switch format {
        case .markdown:
            try container.encode("Update this", forKey: .markdown)
            try container.encode(estimatedMinutes, forKey: .estimatedMinutes)
        case .video:
            try container.encodeIfPresent(videoTitle, forKey: .videoTitle)
            try container.encodeIfPresent(videoDescription, forKey: .videoDescription)
            try container.encodeIfPresent(videoAuthors, forKey: .videoAuthors)
        }
        
        try container.encode(accessLevel, forKey: .accessLevel)
        try container.encode(published, forKey: .published)
        
        if !learningObjectives.isEmpty {
            try container.encodeIfPresent(learningObjectives, forKey: .learningObjectives)
        }
    }
}

extension Instruction {
    var type: ContentType {
        return .instruction
    }
}

