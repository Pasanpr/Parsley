//
//  CodeChallenge.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

public struct CodeChallenge: Encodable {
    let title: String
    
    private enum CodingKeys: String, CodingKey {
        case type
        case title
        case sha
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let typeDescription = String(describing: type(of: self))
        try container.encode(typeDescription, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(" ", forKey: .sha)
    }
}
