//
//  Frontmatter.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

enum FrontmatterError: Error {
    case invalidFrontmatter
    case missingFrontmatter
}

fileprivate enum FrontmatterParseState {
    case multiline
    case regular
}

public struct Frontmatter<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    
    public typealias Block = MarkdownBlock<View, DefinitionStore.Definition>
    
    var contents: String
    
    init(block: ParagraphBlock<View, DefinitionStore.Definition>, source: View, codec: Codec.Type) throws {
        //        self.contents = try block.text.reduce("") { (accumulator: String, current: MarkdownInline<View, DefinitionStore>) throws -> String in
        //            switch current {
        //            case .text(let text):
        //                return accumulator + Codec.string(fromTokens: source[text.span])
        //            default:
        //                throw FrontmatterError.invalidFrontmatter
        //            }
        //        }
        
        self.contents = try block.text.reduce("") { (accumulator, current) -> String in
            switch current {
            case .text(let t):
                return accumulator + Codec.string(fromTokens: source[t.span])
            case .softbreak:
                return accumulator + "\n"
            default:
                throw FrontmatterError.invalidFrontmatter
            }
            
        }
        
        sanitizeYaml()
    }
    
    private func sanitizeYaml() {
        
    }
}

extension String {
    fileprivate var isYamlKeyValuePair: Bool {
        return self.contains(":")
    }
    
    fileprivate var containsYamlMultilineString: Bool {
        return self.contains("|")
    }
}
