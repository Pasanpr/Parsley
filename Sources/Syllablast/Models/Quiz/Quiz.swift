//
//  Quiz.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

struct QuizLearningObjective: Encodable {
    let title: String
    let topic: Topic
}

extension QuizLearningObjective: Equatable {
    static func ==(lhs: QuizLearningObjective, rhs: QuizLearningObjective) -> Bool {
        return lhs.title == rhs.title && lhs.topic == rhs.topic
    }
}

final class Quiz: Encodable {
    let title: String
    let totalQuestions: Int
    let shuffleQuestions: Bool
    let usesMarkdown: Bool
    let questions: [QuizQuestion]
    
    private enum CodingKeys: String, CodingKey {
        case type
        case title
        case description
        case totalQuestions = "total_questions"
        case shuffleQuestions = "shuffle_questions"
        case usesMarkdown = "uses_markdown"
        case questions
    }
    
    init(title: String, totalQuestions: Int, shuffleQuestions: Bool, usesMarkdown: Bool, questions: [QuizQuestion]) {
        self.title = title
        self.totalQuestions = totalQuestions
        self.shuffleQuestions = shuffleQuestions
        self.usesMarkdown = usesMarkdown
        self.questions = questions
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let typeDescription = String(describing: type(of: self))
        try container.encode(typeDescription, forKey: .type)
        
        try container.encode(title, forKey: .title)
        try container.encode(".", forKey: .description)
        try container.encode(totalQuestions, forKey: .totalQuestions)
        try container.encode(shuffleQuestions, forKey: .shuffleQuestions)
        try container.encode(usesMarkdown, forKey: .usesMarkdown)
        try container.encode(questions, forKey: .questions)
    }
    
    public func assessedLearningObjectives(from learningObjectives: [Int]) -> [Int] {
        return learningObjectives.filter { id in
            questions.map({ $0.isAssociatedWithLearningObjective(id: id) }).contains(true)
        }
    }
}
