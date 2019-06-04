//
//  Section.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

struct Section<View, DefinitionStore> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol {
    typealias Block = MarkdownBlock<View, DefinitionStore>
    
    let mode: RecordingMode
    let content: Queue<Block>
}

extension RecordingMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .onSet: return "On Set"
        case .screencast: return "Screencast"
        }
    }
}

extension Section {
    func rawOutput<Codec: MarkdownParserCodec>(source: View, codec: Codec.Type) throws -> String where View.Element == Codec.CodeUnit {
        var output = "### " + mode.description + String.newlines(1)
        
        output += try content.reduce("") { (acc, block) in
            switch block {
            case .paragraph(let p):
                let paragraph = try Paragraph(block: p, source: source, codec: codec.self)
                return acc + paragraph.text
            default:
                return acc
            }
        }
        
        return output
    }
}
