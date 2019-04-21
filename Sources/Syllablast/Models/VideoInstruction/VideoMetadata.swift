//
//  VideoMetadata.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark
import Yams

public struct VideoMetadata<View, Codec>: Decodable where View: BidirectionalCollection, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    let description: String
    let accessLevel: AccessLevel
    let published: Bool
    let authors: [Author]
    
    enum CodingKeys: String, CodingKey {
        case description
        case accessLevel = "access_level"
        case published
        case authors
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decode(String.self, forKey: .description)
        self.accessLevel = try container.decodeIfPresent(AccessLevel.self, forKey: .accessLevel) ?? .basic
        self.published = try container.decodeIfPresent(Bool.self, forKey: .published) ?? false
        self.authors = try container.decodeIfPresent([Author].self, forKey: .authors) ?? []
    }
}

extension VideoMetadata {
    public static func videoMetadataFromYaml(_ source: String) throws -> VideoMetadata<View, Codec> {
        let decoder = YAMLDecoder()
        return try decoder.decode(VideoMetadata<View, Codec>.self, from: source)
    }
}
