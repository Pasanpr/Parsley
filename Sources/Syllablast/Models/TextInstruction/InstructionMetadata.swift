//
//  InstructionMetadata.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/20/19.
//

import Foundation
import SwiftMark
import Yams

public struct InstructionMetadata<View, Codec>: Decodable where View: BidirectionalCollection, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    let description: String
    let format: InstructionFormat
    let accessLevel: AccessLevel
    let published: Bool
    let estimatedMinutes: Int
    var videoTitle: String?
    var videoDescription: String?
    var videoAuthors: [Author]?
    var videoSource: String?
    
    
    enum CodingKeys: String, CodingKey {
        case description
        case format
        case accessLevel = "access_level"
        case published
        case estimatedMinutes = "estimated_minutes"
        case videoTitle = "video_title"
        case videoDescription = "video_description"
        case videoAuthors = "video_authors"
        case videoSource = "video_source"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decode(String.self, forKey: .description)
        self.format = try container.decode(InstructionFormat.self, forKey: .format)
        self.accessLevel = try container.decodeIfPresent(AccessLevel.self, forKey: .accessLevel) ?? .basic
        self.published = try container.decodeIfPresent(Bool.self, forKey: .published) ?? true
        self.estimatedMinutes = try container.decode(Int.self, forKey: .estimatedMinutes)
        self.videoTitle = try container.decodeIfPresent(String.self, forKey: .videoTitle)
        self.videoDescription = try container.decodeIfPresent(String.self, forKey: .videoDescription)
        self.videoAuthors = try container.decodeIfPresent([Author].self, forKey: .videoAuthors)
        self.videoSource = try container.decodeIfPresent(String.self, forKey: .videoSource)
    }
}

extension InstructionMetadata {
    public static func instructionMetadataFromYaml(_ source: String) throws -> InstructionMetadata<View, Codec> {
        let decoder = YAMLDecoder()
        return try decoder.decode(InstructionMetadata<View, Codec>.self, from: source)
    }
}

