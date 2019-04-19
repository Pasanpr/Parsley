//
//  LineLexerStructures.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

/// The kind of a fence
enum FenceKind { case backtick, tilde }

/// The kind of a list
enum ListKind {
    enum BulletKind { case star, hyphen, plus }
    enum NumberKind { case dot, parenthesis }
    
    /// ListKind for an unordered list
    case bullet(BulletKind)
    /// ListKind for an ordered list
    case number(NumberKind, Int)
    
    /// Gives the textual width of `self`.
    /// Examples:
    /// - A Bullet list has a width of 1 (the bullet + space after it)
    /// - A Number list with the number 23 has a width of 3 (two digits of 23 + dot or parenthesis + space)
    var width: Int {
        switch self {
            
        case .bullet:
            return 1
            
        case .number(_, var value):
            var width = 2
            while value > 9 {
                (value, width) = (value / 10, width + 1)
            }
            return width
        }
    }
}

/// Returns true iff `lhs` is equal to `rhs`, ignoring the number of a Number kind.
func ~= (lhs: ListKind, rhs: ListKind) -> Bool {
    switch (lhs, rhs) {
        
    case let (.bullet(l), .bullet(r)):
        return l == r
        
    case let (.number(kl, _), .number(kr, _)):
        return kl == kr
        
    case _:
        return false
    }
}

indirect enum LineKind<View, RefDef> where View: BidirectionalCollection, RefDef: ReferenceDefinitionProtocol {
    case list(ListKind, Line<View, RefDef>)
    case quote(Line<View, RefDef>)
    case text
    case header(Range<View.Index>, Int32)
    case fence(FenceKind, Range<View.Index>, Int32)
    case thematicBreak
    case empty
    case reference(Range<View.Index>, Range<View.Index>)
    
    var isEmpty: Bool {
        switch self {
        case .empty: return true
        default: return false
        }
    }
}

let TAB_INDENT = 4

enum IndentKind {
    case space
    case tab
    
    var width: Int {
        switch self {
        case .space: return 1
        case .tab: return TAB_INDENT
        }
    }
    
    init?<Codec: MarkdownParserCodec>(_ token: Codec.CodeUnit, codec: Codec.Type) {
        switch token {
        case Codec.space: self = .space
        case Codec.tab: self = .tab
        default: return nil
        }
    }
}

struct Indent {
    var length: Int = 0
    
    mutating func add(_ kind: IndentKind) {
        self.length += kind.width
    }
}

struct Line<View, RefDef> where View: BidirectionalCollection, RefDef: ReferenceDefinitionProtocol {
    let kind: LineKind<View, RefDef>
    var indent: Indent
    var indices: Range<View.Index>
    
    init(_ kind: LineKind<View, RefDef>, _ indent: Indent, _ indices: Range<View.Index>) {
        self.kind = kind
        self.indent = indent
        self.indices = indices
    }
}

extension MarkdownParser {
    func restoreIndentInLine(_ line: inout Line) {
        var indent = line.indent.length
        var i = line.indices.lowerBound
        
        while indent > 0 {
            view.formIndex(before: &i)
            let kind = IndentKind(view[i], codec: Codec.self)!
            indent -= kind.width
        }
        
        line.indices = i ..< line.indices.upperBound
    }
}
