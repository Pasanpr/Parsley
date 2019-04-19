//
//  Fence.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

public struct Fence<View, Codec> where View:BidirectionalCollection, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    let name: String
    let body: String
    
    init(block: FenceBlock<View>, source: View, codec: Codec.Type) {
        self.name = Codec.string(fromTokens: source[block.name])
        if let first = block.text.first {
            self.body = block.text.dropFirst().reduce(Codec.string(fromTokens: source[first])) { acc, cur in
                return acc + "\n" + Codec.string(fromTokens: source[cur])
            }
        } else {
            self.body = ""
        }
    }
    
    public var isEmpty: Bool {
        return self.body.isEmpty
    }
}
