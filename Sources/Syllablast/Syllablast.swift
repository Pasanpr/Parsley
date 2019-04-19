import Foundation
import SwiftMark
import Yams

enum SyllablastError: Error {
    case missingFrontmatter
}

public final class Syllablast<View, DefinitionStore, Codec> where View: BidirectionalCollection, DefinitionStore: ReferenceDefinitionStore, Codec: MarkdownParserCodec, View.Element == Codec.CodeUnit {
    
    private let source: View
    private let markdown: Markdown<View, DefinitionStore, Codec>
    private let decoder = YAMLDecoder()
    
    public init(source: View, definitionStore: DefinitionStore, codec: Codec.Type) {
        self.source = source
        self.markdown = Markdown(source: source, definitionStore: definitionStore, codec: codec.self)
    }
    
    private var isAtEnd: Bool {
        return markdown.isAtEnd
    }
    
    public func generateAdminYaml() throws -> String {
        return ""
    }
    
    private func generateSyllabus() throws -> Course {
        var course = try generateCourseShell(codec: Codec.self)
        let stages = try generateStages()
        //        course.stages.append(contentsOf: stages)
        
        return course
    }
    
    private func generateCourseShell(codec: Codec.Type) throws -> Course {
        let frontmatter = try readFrontmatter(source: source, codec: codec.self)
        return try decoder.decode(Course.self, from: frontmatter.contents)
    }
    
    private func readFrontmatter(source: View, codec: Codec.Type) throws -> Frontmatter<View, DefinitionStore, Codec> {
        return try markdown.frontmatter(source: source, codec: codec.self)
    }
    
    private func generateStages() -> [Stage] {
        var stages: [Stage] = []
        while !isAtEnd {
            let stage = generateStage()
            stages.append(stage)
        }
        
        return stages
    }
    
    private func generateStage() -> Stage {
        return Stage(title: "", description: "", topicsCovered: [])
    }
    
}
