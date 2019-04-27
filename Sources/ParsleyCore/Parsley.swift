import Syllablast
import SwiftMark
import Files

enum ParsleyError: Error {
    case missingScripts
    
    var localizedDescription: String {
        switch self {
        case .missingScripts: return "Unable to find scripts folder. Make sure you're running parsley in the root directory of the project"
        }
    }
}

public final class Parsley {
    /// Generates admin.yml file from scripts
    ///
    /// Scripts must be located in a `scripts` directory and can named either
    /// `scripts.md` or following the `Stage-X.md` convention
    public static func generateAdmin(path: String) throws {
        let syllablast = try generateSyllablastFromScripts(at: path)
        let yaml = try syllablast.generateAdminYaml()
        
        let folder = try Folder(path: path).createSubfolderIfNeeded(withName: "admin")
        let admin = try folder.createFileIfNeeded(withName: "admin.yml")
        try admin.write(string: yaml)
    }
    
    public static func generateLearningObjectives() throws {
        
    }
    
    public static func generateNotes(path: String) throws {
        let syllablast = try generateSyllablastFromScripts(at: path)
        print(try syllablast.generateNotes())
    }
    
}

extension Parsley {
    private static func generateSyllablastFromScripts(at path: String) throws -> Syllablast<String, DefaultReferenceDefinitionStore, CharacterMarkdownCodec> {
        let source = try scripts(at: path)
        return Syllablast(source: source, definitionStore: DefaultReferenceDefinitionStore(), codec: CharacterMarkdownCodec.self)
    }
    
    private static func concatenatedScripts(files: [File]) throws -> String {
        return try files.reduce("") { accumulator, file in
            return try accumulator + file.readAsString()
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
