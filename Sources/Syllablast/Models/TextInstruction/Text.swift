//
//  Text.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

final class Instruction: Content, Encodable {
    let title: String
    let description: String
    let format: TextFormat
    let markdown: String?
    let videoTitle: String?
    let videoDescription: String?
    let videoAuthors: [Author]
    let accessLevel: AccessLevel
    let published: Bool
    let estimatedMinutes: Int
    let learningObjectives: [LearningObjective]
    let topic: Topic
    
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case description
        case format
        case accessLevel = "access_level"
        case published
        case estimatedMinutes = "estimated_minutes"
        case markdown
        case learningObjectives = "learning_objectives"
        
        // Video Based
        
        case videoTitle = "video_title"
        case videoDescription = "video_description"
        case videoAuthors = "video_authors"
    }
    
    init(title: String, description: String, markdown: String, accessLevel: AccessLevel, estimatedMinutes: Int, learningObjectives: [LearningObjective], topic: Topic) {
        self.title = title
        self.description = description
        self.format = .markdown
        self.markdown = markdown
        self.learningObjectives = learningObjectives
        self.published = false
        self.estimatedMinutes = estimatedMinutes
        self.videoTitle = nil
        self.videoDescription = nil
        self.videoAuthors = []
        self.accessLevel = accessLevel
        self.topic = topic
    }
    
    init(title: String, description: String, videoTitle: String, videoDescription: String, videoAuthors: [Author], accessLevel: AccessLevel, estimatedMinutes: Int, learningObjectives: [LearningObjective], topic: Topic) {
        self.title = title
        self.description = description
        self.format = .video
        self.markdown = nil
        self.learningObjectives = learningObjectives
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
        let typeName = String(describing: type(of: self))
        try container.encode(typeName, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(format, forKey: .format)
        
        switch format {
        case .markdown:
            try container.encodeIfPresent(markdown, forKey: .markdown)
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

