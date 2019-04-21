//
//  ReferenceDefinition.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/20/19.
//

import Foundation
import SwiftMark

public struct ReferenceDefintion<View, RefDef, Codec> where View:BidirectionalCollection, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    
    public let title: String
    public let definition: String
    
    init(block: ReferenceDefinitionBlock<View, RefDef>, source: View, codec: Codec.Type) {
        self.title = Codec.string(fromTokens: source[block.key])
        self.definition = Codec.string(fromTokens: source[block.definition])
    }
}
