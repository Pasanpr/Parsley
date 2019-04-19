//
//  Text.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

final class Text: Instruction, Step {
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
    
    init(title: String, description: String, markdown: String, accessLevel: AccessLevel, estimatedMinutes: Int, learningObjectives: [LearningObjective]) {
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
    }
    
    init(title: String, description: String, videoTitle: String, videoDescription: String, videoAuthors: [Author], accessLevel: AccessLevel, estimatedMinutes: Int, learningObjectives: [LearningObjective]) {
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
    }
}

