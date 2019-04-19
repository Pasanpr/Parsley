//
//  LearningObjective.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

class LearningObjective {
    let id: Int
    weak var parent: Instruction?
    let title: String
    let cognitiveLevel: CognitiveLevel
    let topic: Topic
    
    init(id: Int, parent: Instruction, title: String, cognitiveLevel: CognitiveLevel, topic: Topic) {
        self.id = id
        self.parent = parent
        self.title = title
        self.cognitiveLevel = cognitiveLevel
        self.topic = topic
    }
}
