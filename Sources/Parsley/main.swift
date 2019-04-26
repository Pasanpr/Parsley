import ParsleyCore
import Commander
import Darwin

/*
 Parsley
 ----------
 Easily automate Treehouse admin tasks.
 
 Commands:
 
 generate                   Requires subcommand listed below
 lint                       Validates scripts for gendered and non-beginner friendly language
 help                       Display this information
 
 Subcommand:
 
 --admin                    Generate admin.yml file for course uploads.
                            Created at target path admin/ by default
 --learning-objectives      Generate list of learning objectives for course
 Created at target path scripts/ by default
 --intro-email              Randomly generate a badge unlock email for the first stage
 --outro-email              Randomly generate a badge unlock email for the last stage
 */

Group {
    $0.command("generate",
               Flag("admin", description: "Generate admin.yml file for course uploads. Created at target path admin/ by default"),
               Flag("learning-objectives", description: ""),
               Option("path", default: "", description: "Path to scripts folder"),
               description: "Generates files. Requires subcommand")
    { admin, learningObjectives, path in
        if admin {
            do {
                try Parsley.generateAdmin(path: path)
            }
        } else if learningObjectives  {
            try Parsley.generateLearningObjectives()
        } else {
            fputs("generate requires a subcommand. Run parsley --help for help!", stderr)
        }
    }
    
    $0.command("lint") {
        print("Lint scripts")
    }
}.run()
