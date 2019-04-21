//
//  Stage.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark
import Yams

public struct StageMetadata<View, DefinitionStore, Codec>: Codable where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    let description: String
    let topics: [String]
    let topicsCovered: [String]
    
    enum CodingKeys: String, CodingKey {
        case description
        case topics
        case topicsCovered = "topics_covered"
    }
}

extension StageMetadata {
    public static func stageMetadataFromYaml(_ source: String) throws -> StageMetadata<View, DefinitionStore, Codec> {
        let decoder = YAMLDecoder()
        return try decoder.decode(StageMetadata<View, DefinitionStore, Codec>.self, from: source)
    }
}

public final class Stage<View, DefinitionStore, Codec>: Encodable where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    let title: String
    let description: String
    let topics: [String]
    let topicsCovered: [String]
    var steps: [Step<View, DefinitionStore>] = []
    
    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case topics
        case topicsCovered = "topics_covered"
        case steps
    }
    
    init(title: String, description: String, topics: [String], topicsCovered: [String]) {
        self.title = title
        self.description = description
        self.topics = topics
        self.topicsCovered = topicsCovered
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(topics, forKey: .topics)
        try container.encode(topicsCovered, forKey: .topicsCovered)
        try container.encode(steps, forKey: .steps)
    }
}

extension Stage {
    public convenience init<View, DefinitionStore, Codec>(title: String, metadata: StageMetadata<View, DefinitionStore, Codec>) where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
        self.init(title: title, description: metadata.description, topics: metadata.topics, topicsCovered: metadata.topicsCovered)
    }
}
