//
//  LearningObjective.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

class LearningObjective: Encodable {
    let id: Int
    weak var parent: Content?
    let title: String
    let cognitiveLevel: CognitiveLevel
    let topic: Topic
    
    enum CodingKeys: String, CodingKey {
        case title
        case cognitiveLevel = "cognitive_level"
        case topic
    }
    
    init(id: Int, parent: Content, title: String, cognitiveLevel: CognitiveLevel, topic: Topic) {
        self.id = id
        self.parent = parent
        self.title = title
        self.cognitiveLevel = cognitiveLevel
        self.topic = topic
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(cognitiveLevel, forKey: .cognitiveLevel)
        try container.encode(topic, forKey: .topic)
    }
}
