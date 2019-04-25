//
//  QuizQuestion.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/22/19.
//

import Foundation

enum QuizQuestion: Encodable {
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
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .multipleChoice(let mc):
            try mc.encode(to: encoder)
        default:
            fatalError()
        }
    }
}
