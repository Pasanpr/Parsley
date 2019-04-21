//
//  Header.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

public enum HeaderLevel: Int {
    case stage = 1
    case step = 2
    case recordingMode = 3
}

enum HeaderError: Error {
    case missingHeader
    case invalidHeader
}

public struct Header<View, RefDef, Codec> where View:BidirectionalCollection, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    
    let level: HeaderLevel
    let text: String
    
    init(block: HeaderBlock<View, RefDef>, source: View, codec: Codec.Type) throws {
        self.level = HeaderLevel(rawValue: block.level)!
        self.text = try block.text.reduce("") { (accumulator, current) -> String in
            switch current {
            case .text(let t):
                return accumulator + Codec.string(fromTokens: source[t.span])
            default:
                throw HeaderError.invalidHeader
            }
            
        }
    }
    
    public var isStageTitle: Bool {
        return level == .step
    }
    
    public var isStepTitle: Bool {
        return level == .step
    }
    
    public var isRecordingModeIdentifier: Bool {
        return level == .recordingMode
    }
}
