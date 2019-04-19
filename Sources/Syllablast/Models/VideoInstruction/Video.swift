//
//  Video.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

final class Video: Instruction, Step {
    let title: String
    let description: String
    let accessLevel: AccessLevel
    let published: Bool
    let scripts: Scripts
    let learningObjectives: [LearningObjective]
    let notes: String
    let authors: [Author]
    
    init(title: String, description: String, accessLevel: AccessLevel, published: Bool, scripts: Scripts, learningObjectives: [LearningObjective], notes: String, authors: [Author]) {
        self.title = title
        self.description = description
        self.accessLevel = accessLevel
        self.published = published
        self.scripts = scripts
        self.learningObjectives = learningObjectives
        self.notes = notes
        self.authors = authors
    }
}
