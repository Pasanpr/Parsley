//
//  Paragraph.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/20/19.
//

import Foundation
import SwiftMark

public struct Paragraph<View, RefDef, Codec> where View:BidirectionalCollection, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    
    let text: String
    
    init(block: ParagraphBlock<View, RefDef>, source: View, codec: Codec.Type) throws {
        self.text = block.text.reduce("") { (accumulator, current) -> String in
            switch current {
            case .text(let t):
                return accumulator + Codec.string(fromTokens: source[t.span])
            case .reference(let ref):
                return accumulator + ref.title.reduce("") { (acc, curr) -> String in
                    switch curr {
                    case .text(let t): return acc + "[\(Codec.string(fromTokens: source[t.span]))]"
                    default:
                        fatalError()
                    }
                }
                
            default:
                fatalError()
            }
            
        }
    }
}
