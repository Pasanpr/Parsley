//
//  Step.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

enum Step<View, DefinitionStore>: Encodable where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol {
    case video(Video<View, DefinitionStore>)
    case instruction(Instruction<View, DefinitionStore>)
    case codeChallenge(CodeChallenge)
    case quiz(Quiz)
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .video(let video):
            try video.encode(to: encoder)
        case .instruction(let instruction):
            try instruction.encode(to: encoder)
        case .codeChallenge(let cc):
            try cc.encode(to: encoder)
        case .quiz(let quiz):
            try quiz.encode(to: encoder)
        }
    }
}

enum StepType: String {
    case video = "Video"
    case instruction = "Instruction"
    case codeChallenge = "Code"
    case quiz = "Quiz"
}

extension Step {
    var isQuiz: Bool {
        switch self {
        case .quiz: return true
        default: return false
        }
    }
    
    var quiz: Quiz? {
        switch self {
        case .quiz(let q): return q
        default: return nil
        }
    }
    
    var isInstruction: Bool {
        switch self {
        case .instruction: return true
        default: return false
        }
    }
    
    var instruction: Instruction<View, DefinitionStore>? {
        switch self {
        case .instruction(let i): return i
        default: return nil
        }
    }
    
    var isVideo: Bool {
        switch self {
        case .video: return true
        default: return false
        }
    }
    
    var video: Video<View, DefinitionStore>? {
        switch self {
        case .video(let v): return v
        default: return nil
        }
    }
}

extension Step {
    var learningObjectives: String {
        switch self {
        case .video(let video): return video.learningObjectivesDescription
        case .instruction(let instruction): return instruction.learningObjectivesDescription
        default: return ""
        }
    }
}
