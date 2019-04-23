//
//  Quiz.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

struct QuizFormatSpecifier {
    struct OptionsKey {
        static let shouldShuffleAnswers = "shouldShuffleAnswers"
        static let trueFalseAnswer = "trueFalseAnswer"
    }
    
    let type: String.SubSequence
    let associatedLearningObjectiveId: Int
    let options: [String: Bool]
    
    init(formatSpecifierStringComponents: [String.SubSequence]) {
        var options = [String: Bool]()
        guard let quizType = formatSpecifierStringComponents.first, let associatedLOString = formatSpecifierStringComponents.last?.dropFirst(), let associatedLO = Int(associatedLOString) else {
            fatalError("Quiz question type and LO cannot be missing")
        }
        
        let remainder = formatSpecifierStringComponents.dropFirst().dropLast()
        
        if !remainder.isEmpty {
            guard let boolValue = remainder.first else {
                fatalError()
            }
            
            switch quizType {
            case "mc":
                options[OptionsKey.shouldShuffleAnswers] = Bool(String(boolValue))
            case "tf":
                options[OptionsKey.trueFalseAnswer] = Bool(String(boolValue))
            default:
                break
                
            }
        }
        
        self.type = quizType
        self.associatedLearningObjectiveId = associatedLO
        self.options = options
    }
    
    var shouldShuffleAnswers: Bool {
        return options[QuizFormatSpecifier.OptionsKey.shouldShuffleAnswers] ?? true
    }
}

enum QuizQuestion {
    case multipleChoice(MultipleChoiceQuestion)
    case fitb(FillInTheBlankQuestion)
    case trueFalse(TrueFalseQuestion)
    
    var description: String {
        switch self {
        case .multipleChoice: return "MultipleChoice"
        case .fitb: return "FillInTheBlank"
        case .trueFalse: return "TrueFalse"
        }
    }
}

final class Quiz: Encodable {
    let title: String
    let totalQuestions: Int
    let shuffleQuestions: Bool
    let usesMarkdown: Bool
    let questions: [QuizQuestion]
    
    init(title: String, totalQuestions: Int, shuffleQuestions: Bool, usesMarkdown: Bool, questions: [QuizQuestion]) {
        self.title = title
        self.totalQuestions = totalQuestions
        self.shuffleQuestions = shuffleQuestions
        self.usesMarkdown = usesMarkdown
        self.questions = questions
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}

final class MultipleChoiceQuestion {
    let question: String
    let associatedLearningObjective: LearningObjective
    let shuffleAnswers: Bool
    let answers: [MultipleChoiceAnswer]
    
    init(question: String, associatedLearningObjective: LearningObjective, shuffleAnswers: Bool, answers: [MultipleChoiceAnswer]) {
        self.question = question
        self.associatedLearningObjective = associatedLearningObjective
        self.shuffleAnswers = shuffleAnswers
        self.answers = answers
    }
}

final class MultipleChoiceAnswer {
    let id: String?
    let answer: String
    let isCorrect: Bool
    var feedback: String?
    
    init(id: String?, answer: String, isCorrect: Bool, feedback: String? = nil) {
        self.id = id
        self.answer = answer
        self.isCorrect = isCorrect
        self.feedback = feedback
    }
    
    func addFeedback(_ feedback: String) {
        self.feedback = feedback
    }
}

extension MultipleChoiceAnswer: CustomStringConvertible {
    var description: String {
        return "id:\(id)\nanswer: \(answer)\nisCorrect: \(isCorrect)\nfeedback: \(feedback)"
    }
}

struct FillInTheBlankQuestion {
    let question: String
    let associatedLearningObjective: LearningObjective
    let answers: [FillInTheBlankAnswer]
}

struct FillInTheBlankAnswer {
    let blankIndex: Int
    let answer: String
    let usesStringValidation: Bool
    let isCanonical: Bool
}

struct TrueFalseQuestion {
    let question: String
    let associatedLearningObjective: LearningObjective
    let answer: Bool
    let trueFeedback: String?
    let falseFeedback: String?
}

