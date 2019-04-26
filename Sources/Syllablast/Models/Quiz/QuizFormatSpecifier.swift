//
//  QuizFormatSpecifier.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/22/19.
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
    
    var trueFalseAnswer: Bool {
        return options[QuizFormatSpecifier.OptionsKey.trueFalseAnswer]!
    }
}
