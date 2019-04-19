//
//  Stage.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

public struct StageMetadata: Codable {
    let description: String
    let topics: [String]
    let topicsCovered: [String]
    
    enum CodingKeys: String, CodingKey {
        case description
        case topics
        case topicsCovered = "topics_covered"
    }
}

public final class Stage: Codable {
    let title: String
    let description: String
    let topicsCovered: [String]
    //    var steps: [Step] = []
    
    init(title: String, description: String, topicsCovered: [String]) {
        self.title = title
        self.description = description
        self.topicsCovered = topicsCovered
    }
}
