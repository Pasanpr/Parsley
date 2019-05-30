//
//  TrueFalseQuizQuestionBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/25/19.
//

import Foundation
import SwiftMark

fileprivate struct Feedback {
    let `true`: String?
    let `false`: String?
}

final class TrueFalseQuizQuestionBuilder {
    let source: String.SubSequence
    var scanner: SwiftMark.Scanner<String.SubSequence>
    
    init(source: String.SubSequence) {
        self.source = source
        self.scanner = Scanner(data: source)
    }
    
    func generateQuestion(withAnswer answer: Bool, learningObjective lo: LearningObjective) throws -> TrueFalseQuestion {
        let question = parseQuestionString()
        let feedback = try generateFeedback()
        
        return TrueFalseQuestion(question: question, associatedLearningObjective: lo, answer: answer, trueFeedback: feedback.true, falseFeedback: feedback.false)
    }
    
    private func parseQuestionString() -> String {
        let startIndex = scanner.startIndex
        var endIndex = scanner.endIndex
        
        var didReachFeedbackBlockOrEnd = false
        
        // Pop until feedback block
        while !didReachFeedbackBlockOrEnd && scanner.startIndex != scanner.endIndex {
            scanner.popWhile { character in
                guard let character = character else {
                    return .stop
                }
                
                switch character {
                case "[":
                    return .stop
                default:
                    return .pop
                }
            }
            
            let _ = scanner.pop() // Pop the opening square bracket
            // Check if it was an answer block or simply an array delimiter\
            if scanner.peek() == "F" {
                didReachFeedbackBlockOrEnd = true
            }
        }
        
        // Move the index back one to the start of the answer section
        scanner.startIndex = source.index(scanner.startIndex, offsetBy: -1)
        endIndex = scanner.startIndex
        
        return source[startIndex..<endIndex].trimmedWhitespaceAndNewlines()
    }
    
    private func generateFeedback() throws -> Feedback {
        var feedbackSpecifiers: [([String.SubSequence], String)] = []
        
        while scanner.startIndex != source.endIndex {
            feedbackSpecifiers.append(try parseFeedbackString())
            
            while scanner.peek() == "\n" {
                let _ = scanner.pop()
            }
        }
        
        // If there is no feedback provided
        if let components = feedbackSpecifiers.first?.0, components.isEmpty {
            return Feedback(true: nil, false: nil)
        }
        
        var falseFeedback: String? = nil
        var trueFeedback: String? = nil
        
        for (components, feedbackString) in feedbackSpecifiers {
            // Component example:
            // [F-T]
            
            guard let specifier = components.last else {
                throw QuizError.invalidFormatSpecifier
            }
            
            switch specifier {
            case "T":
                trueFeedback = feedbackString
            case "F":
                falseFeedback = feedbackString
            default:
                break
            }
        }
        
        return Feedback(true: trueFeedback, false: falseFeedback)
    }
    
    private func parseFeedbackString() throws -> ([String.SubSequence], String) {
        let componentsStartIndex = scanner.startIndex
        
        scanner.popWhile { character in
            guard let character = character else {
                return .stop
            }
            
            switch character {
            case " ": return .stop
            case _: return .pop
            }
        }
        
        let componentsString = source[componentsStartIndex..<scanner.startIndex]
        let components = componentsString.dropFirst().dropLast().split(separator: "-")
        
        
        let feedbackStartIndex = scanner.startIndex
        
        scanner.popWhile { character in
            guard let character = character else {
                return .stop
            }
            
            switch character {
            case "\n": return .stop
            case _: return .pop
            }
        }
        
        let feedbackString = source[feedbackStartIndex..<scanner.startIndex].trimmedWhitespaceAndNewlines()
        
        return (components, feedbackString)
    }
}
