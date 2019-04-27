//
//  Video.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

final class Video<View, DefinitionStore>: Content, Encodable where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol {
    let title: String
    let description: String
    let accessLevel: AccessLevel
    let published: Bool
    let scripts: Script<View, DefinitionStore>
    var learningObjectives: [LearningObjective] = []
    let topic: Topic
    
    private enum CodingKeys: String, CodingKey {
        case type
        case title
        case description
        case accessLevel = "access_level"
        case published
        case learningObjectives = "learning_objectives"
        case authors
    }
    
    init(title: String, description: String, accessLevel: AccessLevel, published: Bool, scripts: Script<View, DefinitionStore>, authors: [Author], topic: Topic) {
        self.title = title
        self.description = description
        self.accessLevel = accessLevel
        self.published = published
        self.scripts = scripts
        self.topic = topic
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("Video", forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(accessLevel, forKey: .accessLevel)
        try container.encode(published, forKey: .published)
        
        if !learningObjectives.isEmpty {
            try container.encodeIfPresent(learningObjectives, forKey: .learningObjectives)
        }
    }
    
    public func notes<Codec: MarkdownParserCodec>(source: View, codec: Codec.Type) -> String where View.Element == Codec.CodeUnit {
        let fenceBlocks = scripts.sections.map({$0.content.filter({ $0.isFenceBlock }).compactMap({ $0.fenceBlock }).map({ Fence(block: $0, source: source, codec: codec.self) })}).flatMap({$0}).filter({ $0.name.contains("notes") })
        
        var fenceNames = Set(fenceBlocks.map({ $0.name }))
        fenceNames.remove("notes")
        let sectionNames = fenceNames.map({ $0.split(separator: "-") }).map({ $0.dropFirst() }).flatMap({ $0 })
        
        
        let sectionedNotes =  sectionNames.reduce("") { (accumulator, sectionTitle) -> String in
            var section = "#### \(sectionTitle.capitalized)\n\n"
            section += fenceBlocks.filter({ $0.name.contains(sectionTitle) }).reduce("", { (accumulator, fence) in
                return accumulator + fence.body + "\n"
            })
            
            return accumulator + section
        }
        
        let nonSectionedNotes = fenceBlocks.filter({ $0.name == "notes" }).reduce("", { (accumulator, fence) in
            return accumulator + fence.body + "\n"
        })
        
        return "Video - \(title)\n\n" + sectionedNotes + "\n" + nonSectionedNotes
    }
}

extension Video {
    var type: ContentType {
        return .video
    }
}

extension Video {
    func addLearningObjectives(_ learningObjectives: [LearningObjective]) {
        self.learningObjectives = learningObjectives
    }
}
