import Syllablast
import SwiftMark
import Files

public enum ParsleyError: Error {
    case missingScripts
    case missingMetadata(title: String)
    
    var localizedDescription: String {
        switch self {
        case .missingScripts: return "Unable to find scripts folder. Make sure you're running parsley in the root directory of the project"
        case .missingMetadata(let title): return "Whoops! Looks like the \(title) step is missing a YAML code block after the title"
        }
    }
}

public final class Parsley {
    /// Generates admin.yml file from scripts
    ///
    /// Scripts must be located in a `scripts` directory and can named either
    /// `scripts.md` or following the `Stage-X.md` convention
    public static func generateAdmin(path: String) throws {
        do {
            let syllablast = try generateSyllablastFromScripts(at: path)
            let yaml = try syllablast.generateAdminYaml()
            
            let folder = try Folder(path: path).createSubfolderIfNeeded(withName: "admin")
            let admin = try folder.createFileIfNeeded(withName: "admin.yml")
            try admin.write(string: yaml)
        } catch SyllablastError.missingMetadata(let step) {
            throw ParsleyError.missingMetadata(title: step)
        }
    }
    
    public static func generateLearningObjectives(path: String) throws {
        let syllablast = try generateSyllablastFromScripts(at: path)
        let learningObjectives  = try syllablast.generateLearningObjectives()
        
        let folder = try Folder(path: path).subfolder(named: "scripts")
        let learningObjectivesDoc = try folder.createFileIfNeeded(withName: "LearningObjectives.md")
        try learningObjectivesDoc.write(string: learningObjectives)
    }
    
    public static func generateNotes(path: String) throws {
        let syllablast = try generateSyllablastFromScripts(at: path)
        print(try syllablast.generateNotes())
    }
    
    public static func generateAssessmentCoverage(path: String) throws {
        let syllablast = try generateSyllablastFromScripts(at: path)
        print(try syllablast.generateAssessmentCoverage())
    }
    
    public static func generateProductionDocs(path: String) throws {
        let syllablast = try generateSyllablastFromScripts(at: path)
        let scripts = try syllablast.generateScripts()
        let folder = try Folder(path: path).createSubfolderIfNeeded(withName: "production")
        
    }
    
}

extension Parsley {
    public static func generateSyllablastFromScripts(at path: String) throws -> Syllablast<String, DefaultReferenceDefinitionStore, CharacterMarkdownCodec> {
        let source = try scripts(at: path)
        return Syllablast(source: source, definitionStore: DefaultReferenceDefinitionStore(), codec: CharacterMarkdownCodec.self)
    }
    
    private static func concatenatedScripts(files: [File]) throws -> String {
        return try files.reduce("") { accumulator, file in
            return try accumulator + file.readAsString() + "\n"
        }
    }
    
    private static func contentsOfFile(_ file: File) throws -> String {
        return try file.readAsString()
    }
    
    private static func scripts(at path: String) throws -> String {
        var source = ""
        let scriptsPath = path == "" ? "/scripts" : path + "/scripts"
        let scripts: [File] = try Folder(path: scriptsPath).files.enumerated().filter({ return $0.element.name.contains("Stage")}).map({ $0.element })
        
        if scripts.isEmpty {
            // Scripts are named "scripts" or "script"
            guard let file = try Folder(path: scriptsPath).files.enumerated().filter({ return $0.element.name.lowercased().contains("script")}).map({ $0.element }).first else {
                throw ParsleyError.missingScripts
            }
            
            source = try contentsOfFile(file)
        } else {
            source = try concatenatedScripts(files: scripts)
        }
        
        return source
    }
}
