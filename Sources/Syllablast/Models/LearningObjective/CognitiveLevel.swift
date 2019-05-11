//
//  CognitiveLevel.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

enum CognitiveLevel: String, Encodable {
    case recall
    case intepretation
    case synthesis
}

extension CognitiveLevel {
    init(id: Int) {
        switch id {
        case 2: self = .intepretation
        case 3: self = .synthesis
        default: fatalError()
        }
    }
    
    var shortDescription: String {
        switch self {
        case .recall: return "1"
        case .intepretation: return "2"
        case .synthesis: return "3"
        }
    }
}
