//
//  FillInTheBlank.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/23/19.
//

import Foundation

final class FillInTheBlankQuestion: Encodable {
    let question: String
    let associatedLearningObjective: LearningObjective
    fileprivate let learningObjectives: [QuizLearningObjective]
    let blanks: [FillInTheBlankAnswer]
    
    private enum CodingKeys: String, CodingKey {
        case type
        case instruction
        case courseVideo = "course_video"
        case question
        case learningObjectives = "learning_objectives"
        case blanks
    }
    
    init(question: String, associatedLearningObjective: LearningObjective, answers: [FillInTheBlankAnswer]) {
        self.question = question
        self.associatedLearningObjective = associatedLearningObjective
        self.learningObjectives = [QuizLearningObjective(title: associatedLearningObjective.title, topic: associatedLearningObjective.topic)]
        self.blanks = answers
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("FillInTheBlank", forKey: .type)
        
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
        try container.encode(blanks, forKey: .blanks)
    }
}

final class FillInTheBlankAnswer: Encodable {
    let id: String?
    let blankIndex: Int
    let answer: String
    let usesStringValidation: Bool
    let isCanonical: Bool
    var feedback: String?
    
    enum CodingKeys: String, CodingKey {
        case blankIndex = "blank_index"
        case answer
        case usesStringValidation = "use_string_validation"
        case isCanonical = "canonical"
        case feedback
    }
    
    init(id: String?, blankIndex: Int, answer: String, usesStringValidation: Bool, isCanonical: Bool, feedback: String? = nil) {
        self.id = id
        self.blankIndex = blankIndex
        self.answer = answer
        self.usesStringValidation = usesStringValidation
        self.isCanonical = isCanonical
        self.feedback = feedback
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(blankIndex, forKey: .blankIndex)
        try container.encode(answer, forKey: .answer)
        try container.encode(usesStringValidation, forKey: .usesStringValidation)
        try container.encode(isCanonical, forKey: .isCanonical)
        try container.encodeIfPresent(feedback, forKey: .feedback)
    }
    
    func addFeedback(_ feedback: String) {
        self.feedback = feedback
    }
}
