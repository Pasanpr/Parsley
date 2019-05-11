//
//  Scripts.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

struct Script<View, DefinitionStore> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol {
    let sections: [Section<View, DefinitionStore>]
}
