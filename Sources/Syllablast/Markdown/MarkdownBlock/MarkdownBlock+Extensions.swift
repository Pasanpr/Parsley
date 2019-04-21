//
//  MarkdownBlock+Extensions.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

extension MarkdownBlock {
    public var indices: Range<Int> {
        switch self {
        case .paragraph(let p):
            return p.text.indices
        default:
            fatalError()
        }
    }
    
    public var isThematicBreak: Bool {
        switch self {
        case .thematicBreak: return true
        default: return false
        }
    }
    
    public var isParagraphBlock: Bool {
        if case .paragraph = self {
            return true
        } else {
            return false
        }
    }
    
    public var paragraphBlock: ParagraphBlock<View, RefDef>? {
        switch self {
        case .paragraph(let block): return block
        default: return nil
        }
    }
    
    var isHeaderBlock: Bool {
        switch self {
        case .header: return true
        default: return false
        }
    }
    
    public func isHeader(ofLevel level: Int) -> Bool {
        switch self {
        case .header(let h):
            return h.level == level
        default:
            return false
        }
    }
    
    var headerBlock: HeaderBlock <View, RefDef>? {
        switch self {
        case .header(let h): return h
        default: return nil
        }
    }
    
    public var isFenceBlock: Bool {
        switch self {
        case .fence:
            return true
        default: return false
        }
    }
    
    public var fenceBlock: FenceBlock<View>? {
        switch self {
        case .fence(let f): return f
        default: return nil
        }
    }
    
    public var referenceDefinitionBlock: ReferenceDefinitionBlock<View, RefDef>? {
        switch self {
        case .referenceDefinition(let r): return r
        default: return nil
        }
    }
}
