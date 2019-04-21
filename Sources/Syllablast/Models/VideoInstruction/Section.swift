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
