//
//  FillInTheBlank.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/23/19.
//

import Foundation

final class FillInTheBlankQuestion {
    let question: String
    let associatedLearningObjective: LearningObjective
    let answers: [FillInTheBlankAnswer]
    
    init(question: String, associatedLearningObjective: LearningObjective, answers: [FillInTheBlankAnswer]) {
        self.question = question
        self.associatedLearningObjective = associatedLearningObjective
        self.answers = answers
    }
}

final class FillInTheBlankAnswer {
    let id: String?
    let blankIndex: Int
    let answer: String
    let usesStringValidation: Bool
    let isCanonical: Bool
    var feedback: String?
    
    init(id: String?, blankIndex: Int, answer: String, usesStringValidation: Bool, isCanonical: Bool, feedback: String? = nil) {
        self.id = id
        self.blankIndex = blankIndex
        self.answer = answer
        self.usesStringValidation = usesStringValidation
        self.isCanonical = isCanonical
        self.feedback = feedback
    }
    
    func addFeedback(_ feedback: String) {
        self.feedback = feedback
    }
}
