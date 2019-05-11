//
//  Course.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation
import SwiftMark

public final class Syllabus<View, DefinitionStore, Codec>: Codable where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    let course: Course<View, DefinitionStore, Codec>
    
    enum CodingKeys: String, CodingKey {
        case course = "syllabus"
    }
    
    init(course: Course<View, DefinitionStore, Codec>) {
        self.course = course
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(course, forKey: .course)
    }
    
    func notes(source: View, codec: Codec.Type) -> String {
        return course.stages.reduce("", { $0 + $1.notes(source: source, codec: codec.self) })
    }
}

public final class Course<View, DefinitionStore, Codec>: Codable where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionProtocol, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    let title: String
    let topic: Topic
    let courseDescription: String
    let status: Status
    let skillLevel: SkillLevel
    let accessLevel: AccessLevel
    let conceptsCovered: String
    let estimatedPublishDate: String?
    let isVisibleOnRoadmap: Bool
    let responsibleTeacher: String
    var stages: [Stage<View, DefinitionStore, Codec>] = []
    
    enum CodingKeys: String, CodingKey {
        case title
        case topic
        case courseDescription = "description"
        case status
        case skillLevel = "skill_level"
        case accessLevel = "access_level"
        case conceptsCovered = "concepts_covered"
        case estimatedPublishDate = "estimated_publish_date"
        case isVisibleOnRoadmap = "roadmap"
        case responsibleTeacher = "responsible_teacher"
        case stages
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try values.decode(String.self, forKey: .title)
        self.topic = try values.decode(Topic.self, forKey: .topic)
        self.courseDescription = try values.decode(String.self, forKey: .courseDescription)
        self.status = try values.decode(Status.self, forKey: .status)
        self.skillLevel = try values.decodeIfPresent(SkillLevel.self, forKey: .skillLevel) ?? .beginner
        self.accessLevel = try values.decodeIfPresent(AccessLevel.self, forKey: .accessLevel) ?? .basic
        self.conceptsCovered = try values.decodeIfPresent(String.self, forKey: .conceptsCovered) ?? ""
        self.estimatedPublishDate = try values.decodeIfPresent(String.self, forKey: .estimatedPublishDate)
        self.isVisibleOnRoadmap = try values.decodeIfPresent(Bool.self, forKey: .isVisibleOnRoadmap) ?? false
        self.responsibleTeacher = try values.decode(String.self, forKey: .responsibleTeacher)
        self.stages = []
    }
    
    public init(title: String, topic: Topic, description: String, status: Status, skillLevel: SkillLevel, accessLevel: AccessLevel, conceptsCovered: String, estimatedPublishDate: String?, roadmap: Bool, responsibleTeacher teacher: String) {
        self.title = title
        self.topic = topic
        self.courseDescription = description
        self.status = status
        self.skillLevel = skillLevel
        self.accessLevel = accessLevel
        self.conceptsCovered = conceptsCovered
        self.estimatedPublishDate = estimatedPublishDate
        self.isVisibleOnRoadmap = roadmap
        self.responsibleTeacher = teacher
    }
    
    public func addStage(_ stage: Stage<View, DefinitionStore, Codec>) {
        self.stages.append(stage)
    }
    
    var learningObjectives: String {
        return stages.reduce("") { (acc, stage) in
            return acc + stage.learningObjectives
        }
    }
}

extension Course: Equatable {
    public static func ==(lhs: Course, rhs: Course) -> Bool {
        return lhs.title == rhs.title
            && lhs.topic == rhs.topic
            && lhs.description == rhs.description
            && lhs.status == rhs.status
            && lhs.skillLevel == rhs.skillLevel
            && lhs.accessLevel == rhs.accessLevel
            && lhs.conceptsCovered == rhs.conceptsCovered
            && lhs.estimatedPublishDate == rhs.estimatedPublishDate
            && lhs.isVisibleOnRoadmap == rhs.isVisibleOnRoadmap
            && lhs.responsibleTeacher == rhs.responsibleTeacher
    }
}

extension Course: CustomStringConvertible {
    public var description: String {
        return "title: \(title)\ntopic: \(topic)\ndescription: \(courseDescription)\nstatus: \(status)\nskillLevel: \(skillLevel)\naccessLevel: \(accessLevel)\nconceptsCovered: \(conceptsCovered)\npubDate: \(String(describing: estimatedPublishDate))\nroadmap: \(isVisibleOnRoadmap)\nresponsibleTeacher: \(responsibleTeacher)"
    }
}

