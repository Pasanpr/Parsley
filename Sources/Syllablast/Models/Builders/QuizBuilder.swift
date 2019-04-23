//
//  QuizBuilder.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/21/19.
//

import Foundation
import SwiftMark

enum QuizError: Error {
    case invalidQuizBlock
    case invalidFormatSpecifier
}

final class QuizBuilder<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    
    private typealias Block = MarkdownBlock<View, DefinitionStore.Definition>
    private let header: Header<View, DefinitionStore.Definition, Codec>
    private let markdown: Markdown<View, DefinitionStore, Codec>
    private let learningObjectives: Set<LearningObjective>
    
    
    init(header: Header<View, DefinitionStore.Definition, Codec>, markdown: Markdown<View, DefinitionStore, Codec>, learningObjectives: Set<LearningObjective>) {
        self.header = header
        self.markdown = markdown
        self.learningObjectives = learningObjectives
    }
    
    func generateQuiz() throws -> Quiz {
        let title = header.text.split(separator: " ").dropFirst(2).joined(separator: " ")
        let questions = try parseQuizQuestions()
        return Quiz(title: title, totalQuestions: questions.count, shuffleQuestions: true, usesMarkdown: true, questions: questions)
    }
    
    private func parseQuizQuestions() throws -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        while markdown.isNotAtEnd || isAtEndOfStep() {
            let fence = try markdown.fence()
            guard fence.name == "quiz" else {
                throw QuizError.invalidQuizBlock
            }
            
            let question = try parseQuizQuestion(body: fence.body)
            questions.append(question)
            
            // Pop until next quiz question
            let _ = markdown.popWhile { block in
                guard let block = block else {
                    return .stop
                }
                
                switch block {
                case .fence:
                    return .stop
                default:
                    return .pop
                }
            }
        }
        
        return questions
    }
    
    private func parseQuizQuestion(body: String) throws -> QuizQuestion {
        let (formatSpecifier, quizBody) = try readFormatSpecifier(body: body)
        let lo = learningObjective(with: formatSpecifier.associatedLearningObjectiveId)
        
        switch formatSpecifier.type {
        case "mc":
            let shouldShuffleAnswers = formatSpecifier.shouldShuffleAnswers
            let question = try MultipleChoiceQuizQuestionBuilder(source: quizBody).generateQuestion(with: lo, shouldShuffleAnswers: shouldShuffleAnswers)
            return QuizQuestion.multipleChoice(question)
        default:
            fatalError()
        }
    }
    
    private func learningObjective(with id: Int) -> LearningObjective {
        guard let learningObjective = learningObjectives.filter({ $0.id == id }).first else {
            fatalError("Quiz question must have associated learning objective")
        }
        
        return learningObjective
    }
    
    private func readFormatSpecifier(body: String) throws -> (QuizFormatSpecifier, String.SubSequence) {
        // Create new scanner with body of quiz fence
        var scanner = SwiftMark.Scanner(data: body)
        // Mark at start index of body
        let startIndex = scanner.startIndex
        
        // Pop until newline is reached
        // This returns the format specifier at the start of every quiz block
        scanner.popWhile { character in
            guard let character = character else {
                return .stop
            }
            
            switch character {
            case "\n":
                return .stop
            default:
                return .pop
            }
        }
        
        let endIndex = scanner.startIndex
        // Parse out format specifier string
        let parsedString = body[startIndex..<endIndex]
        
        // Assert that delimiter is specified
        let delimiterStartIndex = startIndex
        let delimiterEndIndex = body.index(delimiterStartIndex, offsetBy: 2)
        
        guard parsedString[delimiterStartIndex..<delimiterEndIndex] == "::" else {
            throw QuizError.invalidFormatSpecifier
        }
        
        // Get rid of delimiters once we've validated
        let formatSpecifier = parsedString.dropFirst(2)
        
        // Parse quiz type
        let formatStringComponents = formatSpecifier.split(separator: "-")
        
        return (QuizFormatSpecifier(formatSpecifierStringComponents: formatStringComponents), body[scanner.startIndex..<body.endIndex])
    }
    
    private func isAtEndOfStep() -> Bool {
        guard let next = markdown.peek(), next.isHeader(ofLevel: 2) else {
            return false
        }
        
        return true
    }
}

