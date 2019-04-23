//
//  MultipleChoiceQuizQuestionBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/22/19.
//

import Foundation
import SwiftMark

final class MultipleChoiceQuizQuestionBuilder {
    let source: String.SubSequence
    var scanner: SwiftMark.Scanner<String.SubSequence>
    
    init(source: String.SubSequence) {
        self.source = source
        self.scanner = Scanner(data: source)
    }
    
    func generateQuestion(with lo: LearningObjective, shouldShuffleAnswers shuffle: Bool) throws -> MultipleChoiceQuestion {
        let question = parseQuestionString()
        let answers = try generateAnswers()
        
        return MultipleChoiceQuestion(question: question, associatedLearningObjective: lo, shuffleAnswers: shuffle, answers: answers)
    }
    
    private func parseQuestionString() -> String {
        let startIndex = scanner.startIndex
        var endIndex = scanner.endIndex
        
        var didReachAnswerBlock = false
        
        // Pop until answer set
        while !didReachAnswerBlock {
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
            if scanner.peek() == "A" {
                didReachAnswerBlock = true
            }
        }
        
        // Move the index back one to the start of the answer section
        scanner.startIndex = source.index(scanner.startIndex, offsetBy: -1)
        endIndex = scanner.startIndex
        
        return source[startIndex..<endIndex].trimmedWhitespaceAndNewlines()
    }
    
    private func generateAnswers() throws -> [MultipleChoiceAnswer] {
        var answerSpecifiers: [([String.SubSequence], String)] = []
        
        while scanner.startIndex != source.endIndex {
            answerSpecifiers.append(try parseAnswerString())
            
            while scanner.peek() == "\n" {
                let _ = scanner.pop()
            }
        }
        
        let answers = answerSpecifiers.filter({ $0.0.first == "A" }).map { (components, answer) -> MultipleChoiceAnswer in
            // Components examples:
            // ["A", "1", "true]
            // ["A", "true"]
            // ["A", "1"]
            // ["A"]
            
            let metadata = components.dropFirst()
            
            if metadata.count == 0 {
                // No identifer or "true" was specified
                return MultipleChoiceAnswer(id: nil, answer: answer, isCorrect: false, feedback: nil)
            } else if metadata.count == 1 {
                let value = metadata.first!
                
                switch value {
                case "true":
                    return MultipleChoiceAnswer(id: nil, answer: answer, isCorrect: true, feedback: nil)
                case _:
                    return MultipleChoiceAnswer(id: String(value), answer: answer, isCorrect: false, feedback: nil)
                }
            } else {
                guard let identifier = metadata.first, let _ = Int(identifier) else {
                    fatalError("Quiz answer identifier must be an integer")
                }
                
                guard let isCorrectString = metadata.last, let isCorrect = Bool(String(isCorrectString)) else {
                    fatalError("Incorrect answer specifier. Refer to the Multiple Choice answer syntax")
                }
                
                return MultipleChoiceAnswer(id: String(identifier), answer: answer, isCorrect: isCorrect, feedback: nil)
            }
        }
        
        for (components, feedback) in answerSpecifiers where components.first == "F" {
            guard let identifier = components.last, let _ = Int(identifier) else {
                fatalError("Quiz feedback identifier must be an integer")
            }
            
            guard let question = answers.filter({ $0.id == String(identifier) }).first else {
                fatalError("Feedback ID must have equivalent answer ID")
            }
            
            question.addFeedback(feedback)
        }
        
        return answers
    }
    
    private func parseAnswerString() throws -> ([String.SubSequence], String) {
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
        
        
        let answerStartIndex = scanner.startIndex
        
        scanner.popWhile { character in
            guard let character = character else {
                return .stop
            }
            
            switch character {
            case "\n": return .stop
            case _: return .pop
            }
        }
        
        let answerString = source[answerStartIndex..<scanner.startIndex].trimmedWhitespaceAndNewlines()
        
        return (components, answerString)
    }
    
    // MARK: - Helpers

}

extension StringProtocol {
    func trimmedWhitespaceAndNewlines() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
