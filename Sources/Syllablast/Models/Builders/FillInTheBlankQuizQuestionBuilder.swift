//
//  FillInTheBlankQuizQuestionBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/23/19.
//

import Foundation
import SwiftMark

final class FillInTheBlankQuizQuestionBuilder {
    let source: String.SubSequence
    var scanner: SwiftMark.Scanner<String.SubSequence>
    
    init(source: String.SubSequence) {
        self.source = source
        self.scanner = Scanner(data: source)
    }
    
    func generateQuestion(with lo: LearningObjective) throws -> FillInTheBlankQuestion {
        let question = parseQuestionString()
        let answers = try generateAnswers()
        
        return FillInTheBlankQuestion(question: "", associatedLearningObjective: lo, answers: [])
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
    
    private func generateAnswers() throws -> [FillInTheBlankAnswer] {
        var answerSpecifiers: [([String.SubSequence], String)] = []
        
        while scanner.startIndex != source.endIndex {
            answerSpecifiers.append(try parseAnswerString())
            
            while scanner.peek() == "\n" {
                let _ = scanner.pop()
            }
        }
        
        let answers = answerSpecifiers.filter({ $0.0.first == "A" }).map { (components, answer) -> FillInTheBlankAnswer in
            // Components examples:
            // ["A", "1", "true", "false"]
            
            var metadata = components.dropFirst()
            
            guard let blankIndexString = metadata.first, let blankIndex = Int(String(blankIndexString)) else {
                fatalError("FITB questions must specify blank index")
            }
            
            metadata = metadata.dropFirst()
            
            guard let usesStringValidationString = metadata.first, let usesStringValidation = Bool(String(usesStringValidationString)) else {
                fatalError("FITB questions must specify whether string validation is used")
            }
            
            metadata = metadata.dropFirst()
            
            guard let isCanonicalString = metadata.first, let isCanonical = Bool(String(isCanonicalString)) else {
                fatalError("FITB questions must specify whether answer is canonical")
            }
            
            return FillInTheBlankAnswer(id: nil, blankIndex: blankIndex, answer: answer, usesStringValidation: usesStringValidation, isCanonical: isCanonical)
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
}
