import Foundation
import SwiftMark
import Yams

public enum SyllablastError: Error {
    case missingFrontmatter
    case missingTitle
    case missingMetadata(step: String)
    case missingRecordingMode
    case expectedLearningObjective
}

public final class Syllablast<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    
    private let source: View
    private var markdown: Markdown<View, DefinitionStore, Codec>
    private let decoder = YAMLDecoder()
    private let encoder = YAMLEncoder()
    
    public init(source: View, definitionStore: DefinitionStore, codec: Codec.Type) {
        self.source = source
        self.markdown = Markdown(source: source, definitionStore: definitionStore, codec: codec.self)
    }
    
    private var isAtEnd: Bool {
        return markdown.isAtEnd
    }
    
    // MARK: - Admin
    
    let yamlOpeningDelimiter = "---"
    
    public func generateAdminYaml() throws -> String {
        do {
            let syllabus = try generateSyllabus()
            return try yamlOpeningDelimiter + String.newlines(1) + encoder.encode(syllabus)
        } catch StageBuilderError.invalidStepMetadata(let title) {
            throw SyllablastError.missingMetadata(step: title)
        }
    }
    
    public func generateNotes() throws -> String {
        let syllabus = try generateSyllabus()
        return syllabus.notes(source: markdown.source, codec: markdown.codec)
    }
    
    // MARK: - Learning Objectives
    
    public func generateLearningObjectives() throws -> String {
        let syllabus = try generateSyllabus()
        return syllabus.course.learningObjectives
    }
    
    // MARK: - Assessment Coverage
    
    public func generateAssessmentCoverage() throws -> String {
        let syllabus = try generateSyllabus()
        return syllabus.course.assessmentCoverage
    }
    
    // MARK: - Production Docs
    
    public func generateScripts() throws -> String {
        let syllabus = try generateSyllabus()
        return try syllabus.scripts(source: markdown.source, codec: markdown.codec)
    }
    
    // MARK: - Helpers
    
    public func generateSyllabus() throws -> Syllabus<View, DefinitionStore.Definition, Codec> {
        let course = try generateCourseShell(codec: Codec.self)
        let stages = try generateStages(withTopic: course.topic)
        course.stages.append(contentsOf: stages)
        
        return Syllabus(course: course)
    }
    
    private func generateCourseShell(codec: Codec.Type) throws -> Course<View, DefinitionStore.Definition, Codec> {
        let frontmatter = try readFrontmatter(source: source, codec: codec.self)
        return try decoder.decode(Course.self, from: frontmatter.contents)
    }
    
    private func readFrontmatter(source: View, codec: Codec.Type) throws -> Frontmatter<View, DefinitionStore, Codec> {
        return try markdown.frontmatter()
    }
    
    private func generateStages(withTopic topic: Topic) throws -> [Stage<View, DefinitionStore.Definition, Codec>] {
        var stages: [Stage<View, DefinitionStore.Definition, Codec>] = []
        
        while !isAtEnd {
            let stage = try generateStage(withTopic: topic)
            stages.append(stage)
        }
        
        return stages
    }
    
    private func generateStage(withTopic topic: Topic) throws -> Stage<View, DefinitionStore.Definition, Codec> {
        let stageBuilder = StageBuilder(markdown: self.markdown, topic: topic)
        return try stageBuilder.generateStage()
    }
}
