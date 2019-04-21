//
//  Quiz.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

protocol QuizQuestion {
    var question: String { get }
    var associatedLearningObjective: LearningObjective { get }
}

struct Quiz {
    let title: String
    let totalQuestions: Int
    let shuffleQuestions: Bool
    let usesMarkdown: Bool
    let questions: [QuizQuestion]
}

struct MultipleChoiceQuestion: QuizQuestion {
    let question: String
    let associatedLearningObjective: LearningObjective
    let shuffleAnswers: Bool
    let answers: [MultipleChoiceAnswer]
}

struct MultipleChoiceAnswer {
    let description: String
    let isCorrect: Bool
    let feedback: String?
}

struct FillInTheBlankQuestion: QuizQuestion {
    let question: String
    let associatedLearningObjective: LearningObjective
    let answers: [FillInTheBlankAnswer]
}

struct FillInTheBlankAnswer {
    let blankIndex: Int
    let answer: String
    let isUsingStringValidation: Bool
    let isCanonical: Bool
}

struct TrueFalseQuestion: QuizQuestion {
    let question: String
    let associatedLearningObjective: LearningObjective
    let answer: Bool
    let trueFeedback: String?
    let falseFeedback: String?
}

