//
//  InlineNode.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

public enum ReferenceKind {
    case normal, unwrapped
    
    var textWidth: Int {
        switch self {
        case .normal   : return 1
        case .unwrapped: return 2
        }
    }
}

enum InlineNode<View, RefDef> where View: BidirectionalCollection, RefDef: ReferenceDefinitionProtocol {
    case text(TextInlineNode<View>)
    case nonText(NonTextInlineNode<View, RefDef>)
}

enum NonTextInlineNodeKind <View: BidirectionalCollection, RefDef: ReferenceDefinitionProtocol> {
    indirect case reference(ReferenceKind, title: Range<View.Index>, definition: RefDef)
    case code(Int32)
    case emphasis(Int32)
    case escapingBackslash
}

enum TextInlineNodeKind {
    case text
    case softbreak
    case hardbreak
}

struct TextInlineNode<View> where View: BidirectionalCollection {
    let kind: TextInlineNodeKind
    var start: View.Index
    var end: View.Index
}

struct NonTextInlineNode<View: BidirectionalCollection, RefDef: ReferenceDefinitionProtocol> {
    
    let kind: NonTextInlineNodeKind<View, RefDef>
    var start: View.Index
    var end: View.Index
    
    func contentRange(inView view: View) -> Range<View.Index> {
        switch kind {
        case .reference(_, let title, _):
            return title
        case .code(let l):
            return view.index(start, offsetBy: numericCast(l)) ..< view.index(end, offsetBy: numericCast(-l))
        case .emphasis(let l):
            return view.index(start, offsetBy: numericCast(l)) ..< view.index(end, offsetBy: numericCast(-l))
        case .escapingBackslash:
            return start ..< start
        }
    }
}
