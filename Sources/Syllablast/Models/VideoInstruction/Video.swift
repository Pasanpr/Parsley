//
//  Video.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

final class Video<View, DefinitionStore>: Content, Encodable where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol {
    let title: String
    let description: String
    let accessLevel: AccessLevel
    let published: Bool
    let scripts: Script<View, DefinitionStore>
    var learningObjectives: [LearningObjective] = []
    let notes: Notes
    let authors: [Author]
    let topic: Topic
    
    private enum CodingKeys: String, CodingKey {
        case type
        case title
        case description
        case accessLevel = "access_level"
        case published
        case learningObjectives = "learning_objectives"
        case authors
    }
    
    init(title: String, description: String, accessLevel: AccessLevel, published: Bool, scripts: Script<View, DefinitionStore>, notes: Notes, authors: [Author], topic: Topic) {
        self.title = title
        self.description = description
        self.accessLevel = accessLevel
        self.published = published
        self.scripts = scripts
        self.notes = notes
        self.authors = authors
        self.topic = topic
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let typeName = String(describing: type(of: self))
        try container.encode(typeName, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(accessLevel, forKey: .accessLevel)
        try container.encode(published, forKey: .published)
        try container.encode(authors, forKey: .authors)
        
        if !learningObjectives.isEmpty {
            try container.encodeIfPresent(learningObjectives, forKey: .learningObjectives)
        }
    }
}

extension Video {
    func addLearningObjectives(_ learningObjectives: [LearningObjective]) {
        self.learningObjectives = learningObjectives
    }
}
