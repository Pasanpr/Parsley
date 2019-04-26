//
//  MultipleChoice.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/22/19.
//

import Foundation

final class MultipleChoiceQuestion: Encodable {
    let canSelectMultipleAnswers: Bool
    let question: String
    let associatedLearningObjective: LearningObjective
    fileprivate let learningObjectives: [QuizLearningObjective]
    let shuffleAnswers: Bool
    let answers: [MultipleChoiceAnswer]
    
    init(question: String, associatedLearningObjective: LearningObjective, shuffleAnswers: Bool, answers: [MultipleChoiceAnswer], canSelectMultipleAnswers: Bool) {
        self.question = question
        self.associatedLearningObjective = associatedLearningObjective
        self.learningObjectives = [QuizLearningObjective(title: associatedLearningObjective.title, topic: associatedLearningObjective.topic)]
        self.shuffleAnswers = shuffleAnswers
        self.answers = answers
        self.canSelectMultipleAnswers = canSelectMultipleAnswers
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case instruction
        case courseVideo = "course_video"
        case question
        case shuffleAnswers = "shuffleAnswers"
        case learningObjectives = "learning_objectives"
        case answers
    }
    
    enum LearningObjectiveCodingKeys: String, CodingKey {
        case title
        case topic
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if canSelectMultipleAnswers {
            try container.encode("MultipleChoiceMultipleAnswer", forKey: .type)
        } else {
            try container.encode("MultipleChoice", forKey: .type)
        }
        
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
        try container.encode(shuffleAnswers, forKey: .shuffleAnswers)
        try container.encode(learningObjectives, forKey: .learningObjectives)
        try container.encode(answers, forKey: .answers)
    }
}

final class MultipleChoiceAnswer: Encodable {
    let id: String?
    let answer: String
    let isCorrect: Bool
    var feedback: String?
    
    enum CodingKeys: String, CodingKey {
        case answer
        case isCorrect = "correct"
        case feedback
    }
    
    init(id: String?, answer: String, isCorrect: Bool, feedback: String? = nil) {
        self.id = id
        self.answer = answer
        self.isCorrect = isCorrect
        self.feedback = feedback
    }
    
    func addFeedback(_ feedback: String) {
        self.feedback = feedback
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(answer, forKey: .answer)
        try container.encode(isCorrect, forKey: .isCorrect)
        try container.encodeIfPresent(feedback, forKey: .feedback)
    }
}

extension MultipleChoiceAnswer: CustomStringConvertible {
    var description: String {
        return "\nid:\(id ?? "N/A")\nanswer: \(answer)\nisCorrect: \(isCorrect)\nfeedback: \(feedback ?? "")"
    }
}
