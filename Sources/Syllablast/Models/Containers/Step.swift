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
//        case .quiz(let quiz):
//            try quiz.encode(to: encoder)
        default: fatalError()
        }
    }
}

enum StepType: String {
    case video = "Video"
    case instruction = "Instruction"
    case codeChallenge = "Code"
    case quiz = "Quiz"
}
