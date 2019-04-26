//
//  TrueFalse.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/25/19.
//

import Foundation

struct TrueFalseQuestion: Encodable {
    let question: String
    let associatedLearningObjective: LearningObjective
    fileprivate let learningObjectives: [QuizLearningObjective]
    let answer: Bool
    let trueFeedback: String?
    let falseFeedback: String?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case instruction
        case courseVideo = "course_video"
        case question
        case learningObjectives = "learning_objectives"
        case answer
        case trueFeedback = "true_feedback"
        case falseFeedback = "false_feedback"
    }
    
    init(question: String, associatedLearningObjective: LearningObjective, answer: Bool, trueFeedback: String?, falseFeedback: String?) {
        self.question = question
        self.associatedLearningObjective = associatedLearningObjective
        self.learningObjectives = [QuizLearningObjective(title: associatedLearningObjective.title, topic: associatedLearningObjective.topic)]
        self.answer = answer
        self.trueFeedback = trueFeedback
        self.falseFeedback = falseFeedback
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("TrueFalse", forKey: .type)
        
        guard let parent = associatedLearningObjective.parent else {
            fatalError("Learning Objetives must have a parent content type")
        }
        
        switch parent.type {
        case .video:
            try container.encode(parent.title, forKey: .courseVideo)
        case .instruction:
            try container.encode(parent.title, forKey: .instruction)
        }
        
        try container.encode(question, forKey: .question)
        try container.encode(learningObjectives, forKey: .learningObjectives)
        try container.encodeIfPresent(trueFeedback, forKey: .trueFeedback)
        try container.encodeIfPresent(falseFeedback, forKey: .falseFeedback)
    }
}

