//
//  MarkdownBlock+Output.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

extension MarkdownBlock where RefDef: CustomStringConvertible, View.Element: Hashable & Comparable {
    
    public func headerText<Codec: MarkdownParserCodec>(source: View, codec: Codec.Type) -> String? where View.Element == Codec.CodeUnit {
        switch self {
        case .header(let h):
            return MarkdownBlock.rawOutput(nodes: h.text, source: source, codec: codec.self)
        default: return nil
        }
    }
    
    public func fenceBlockDescription<Codec: MarkdownParserCodec>(source: View, codec: Codec.Type) -> String? where View.Element == Codec.CodeUnit {
        switch self {
        case .fence:
            return MarkdownBlock.rawOutput(node: self, source: source, codec: codec.self)
        default: return nil
        }
    }
}

// MARK: - Raw Output

extension MarkdownBlock where
    View.Iterator.Element: Comparable & Hashable,
    View.SubSequence: Collection,
    View.SubSequence.Iterator.Element == View.Iterator.Element,
    RefDef: CustomStringConvertible
{
    typealias Token = View.Element
    
    func rawOutput<Codec: MarkdownParserCodec>(source: View, codec: Codec.Type) -> String where View.Element == Codec.CodeUnit {
        return MarkdownBlock.rawOutput(nodes: [self], source: source, codec: Codec.self)
    }
    
    static func combineRawOutput <Codec: MarkdownParserCodec> (source: View, codec: Codec.Type) -> (String, MarkdownBlock) -> String
        where Codec.CodeUnit == Token
    {
        return { (acc: String, cur: MarkdownBlock) -> String in
            let appending = rawOutput(node: cur, source: source, codec: Codec.self)
            guard !appending.isEmpty else { return acc }
            return acc + appending + ""
        }
    }
    
    static func combineRawOutput <Codec: MarkdownParserCodec> (source: View, codec: Codec.Type) -> (String, MarkdownInline<View, RefDef>) -> String
        where Codec.CodeUnit == Token
    {
        return { (acc: String, cur: MarkdownInline<View, RefDef>) -> String in
            let appending = rawOutput(node: cur, source: source, codec: Codec.self)
            guard !appending.isEmpty else { return acc }
            return acc + appending
        }
    }
    
    static func rawOutput <Codec: MarkdownParserCodec> (nodes: [MarkdownBlock], source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        return nodes.reduce("", combineRawOutput(source: source, codec: Codec.self))
    }
    
    static func rawOutput <Codec: MarkdownParserCodec> (nodes: [MarkdownInline<View, RefDef>], source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        return nodes.reduce("", combineRawOutput(source: source, codec: Codec.self))
    }
    
    static func rawOutput <Codec: MarkdownParserCodec> (node: MarkdownInline<View, RefDef>, source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        switch node {
            
        case .text(let t):
            return Codec.string(fromTokens: source[t.span])
            
        case .emphasis(let e):
            return "e\(e.level)(" + e.content.reduce("", combineRawOutput(source: source, codec: Codec.self)) + ")"
            
        case .monospacedText(let m):
            return "code(" + m.content.reduce("") { (acc, cur) in
                let next: String
                switch cur {
                case .softbreak, .hardbreak: next = " "
                case .text(let t): next = Codec.string(fromTokens: source[t.span])
                default: fatalError()
                }
                return acc + next
                } + ")"
            
        case .reference(let r):
            let kindDesc = r.kind == .unwrapped ? "uref" : "ref"
            let titleDesc = rawOutput(nodes: r.title, source: source, codec: Codec.self)
            return "[\(kindDesc): \(titleDesc)(\(r.definition))]"
            
        case .hardbreak:
            return "\n"
            
        case .softbreak:
            return " "
        case .escapingBackslash:
            return ""
        }
    }
    
    static func rawOutput <Codec: MarkdownParserCodec> (node: MarkdownBlock, source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        switch node {
            
        case .paragraph(let p):
            return p.text.reduce("", combineRawOutput(source: source, codec: Codec.self))
            
        case .header(let h):
            return h.text.reduce("", combineRawOutput(source: source, codec: Codec.self))
            
        case .code(let c):
            if let first = c.text.first {
                return "Code[" + c.text.dropFirst().reduce(Codec.string(fromTokens: source[first])) { acc, cur in
                    return acc + "\n" + Codec.string(fromTokens: source[cur])
                    } + "]"
            } else {
                return "Code[]"
            }
            
        case .fence(let f):
            let name = Codec.string(fromTokens: source[f.name])
            if let first = f.text.first {
                return "Fence[" + name + "][" + f.text.dropFirst().reduce(Codec.string(fromTokens: source[first])) { acc, cur in
                    return acc + "\n" + Codec.string(fromTokens: source[cur])
                    } + "]"
            } else {
                return "Fence[" + name + "][]"
            }
            
        case .quote(let q):
            return "Quote { " + q.content.reduce("", combineRawOutput(source: source, codec: Codec.self)) + "}"
            
        case .list(let l):
            var itemsDesc = ""
            for item in l.items {
                itemsDesc += "Item { " + item.content.reduce("", combineRawOutput(source: source, codec: Codec.self)) + "}, "
            }
            return "List[\(l.kind)] { " + itemsDesc + "}"
            
            
        case .thematicBreak:
            return "ThematicBreak"
            
        case .referenceDefinition:
            return ""
        }
    }
}

// MARK: - YAML

extension MarkdownBlock where
    View.Iterator.Element: Comparable & Hashable,
    View.SubSequence: Collection,
    View.SubSequence.Iterator.Element == View.Iterator.Element,
    RefDef: CustomStringConvertible
{
    
    static func combineYamlOutput <Codec: MarkdownParserCodec> (source: View, codec: Codec.Type) -> (String, MarkdownBlock) -> String
        where Codec.CodeUnit == Token
    {
        return { (acc: String, cur: MarkdownBlock) -> String in
            let appending = yamlOutput(node: cur, source: source, codec: Codec.self)
            guard !appending.isEmpty else { return acc }
            return acc + appending + ", "
        }
    }
    
    static func combineYamlOutput <Codec: MarkdownParserCodec> (source: View, codec: Codec.Type) -> (String, MarkdownInline<View, RefDef>) -> String
        where Codec.CodeUnit == Token
    {
        return { (acc: String, cur: MarkdownInline<View, RefDef>) -> String in
            let appending = yamlOutput(node: cur, source: source, codec: Codec.self)
            guard !appending.isEmpty else { return acc }
            return acc + appending
        }
    }
    
    static func yamlOutput <Codec: MarkdownParserCodec> (node: MarkdownBlock, source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        switch node {
            
        case .paragraph(let p):
            return p.text.reduce("", combineYamlOutput(source: source, codec: Codec.self))
            
        case .header(let h):
            return "Header(\(h.level), \(h.text.reduce("", combineYamlOutput(source: source, codec: Codec.self))))"
            
        case .code(let c):
            if let first = c.text.first {
                return "Code[" + c.text.dropFirst().reduce(Codec.string(fromTokens: source[first])) { acc, cur in
                    return acc + "\n" + Codec.string(fromTokens: source[cur])
                    } + "]"
            } else {
                return "Code[]"
            }
            
        case .fence(let f):
            let name = Codec.string(fromTokens: source[f.name])
            if let first = f.text.first {
                return "Fence[" + name + "][" + f.text.dropFirst().reduce(Codec.string(fromTokens: source[first])) { acc, cur in
                    return acc + "\n" + Codec.string(fromTokens: source[cur])
                    } + "]"
            } else {
                return "Fence[" + name + "][]"
            }
            
        case .quote(let q):
            return "Quote { " + q.content.reduce("", combineYamlOutput(source: source, codec: Codec.self)) + "}"
            
        case .list(let l):
            var itemsDesc = ""
            for item in l.items {
                itemsDesc += "Item { " + item.content.reduce("", combineYamlOutput(source: source, codec: Codec.self)) + "}, "
            }
            return "List[\(l.kind)] { " + itemsDesc + "}"
            
            
        case .thematicBreak:
            return "ThematicBreak"
            
        case .referenceDefinition:
            return ""
        }
    }
    
    static func yamlOutput <Codec: MarkdownParserCodec> (nodes: [MarkdownInline<View, RefDef>], source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        return nodes.reduce("", combineYamlOutput(source: source, codec: Codec.self))
    }
    
    static func yamlOutput <Codec: MarkdownParserCodec> (node: MarkdownInline<View, RefDef>, source: View, codec: Codec.Type) -> String
        where Codec.CodeUnit == Token
    {
        switch node {
            
        case .text(let t):
            return Codec.string(fromTokens: source[t.span])
            
        case .emphasis(let e):
            return "e\(e.level)(" + e.content.reduce("", combineYamlOutput(source: source, codec: Codec.self)) + ")"
            
        case .monospacedText(let m):
            return "code(" + m.content.reduce("") { (acc, cur) in
                let next: String
                switch cur {
                case .softbreak, .hardbreak: next = " "
                case .text(let t): next = Codec.string(fromTokens: source[t.span])
                default: fatalError()
                }
                return acc + next
                } + ")"
            
        case .reference(let r):
            let kindDesc = r.kind == .unwrapped ? "uref" : "ref"
            let titleDesc = yamlOutput(nodes: r.title, source: source, codec: Codec.self)
            return "[\(kindDesc): \(titleDesc)(\(r.definition))]"
            
        case .hardbreak:
            return "[hardbreak]"
            
        case .softbreak:
            return "\n"
        case .escapingBackslash:
            return ""
        }
    }
}
