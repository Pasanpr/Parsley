# Parsley

A command line tool to automate tasks during course production

## Features

**Automating Admin Tasks**

Assuming you write your scripts locally in Markdown, Parsley can generate a lot of stuff for you that is really annoying to do manually. For Parsley to work its magic however your scripts need to be formatted very precisely. You can review the spec [here](TreehouseMarkdown.md). In the [examples](#examples) section below you can find examples of scripts written according to the spec.  All of the commands below are run in the root directory of the project. Supply a path to the scripts folder to run from anywhere.  

:file_folder: Generate YML file to import course into Treehouse Admin. Created in `admin/` by default.

```bash
$ parsley generate --admin
```

To supply a path use the `--path` argument

```bash
$ parsley generate --admin --path path_to_scripts
```

:school: Generate list of all learning objectives in a course. Useful to get a detailed overview of what a course covers. Created in  `scripts/` by default. 

```bash
$ parsley generate --learning-objectives
```

:100: Generate a report on "assessment coverage". How many of the total Learning Objectives introduced in the course are assessed?

```bash
$ parsley generate --assessment-coverage
```

:musical_note: Output all teacher's notes by video and stage

```bash
$ parsley generate --notes
```

:movie_camera: Generate Scripts, On Set and Motion docs for production with extraneous information (quizzes, ccs, learning objectives, instruction steps) removed and numbering added.

```bash
$ parsley generate --production-docs
```

**Linting**

:mag: Lint scripts for non-beginner friendly and gendered language. Disallowed words are specified [here](). Submit a PR to add to it!

```bash
$ parsley lint
```

## Feature Pipeline

Not implemented yet but on the way!

**Syncing with Drive**

:arrow_up: Upload any file to a path in drive. Not formatted by default. Takes `--formatted` subcommand to format from Markdown to Drive.   
 
```bash
$ parsley upload --formatted path_to_local_file path_on_drive
```

:arrows_clockwise: Sync production docs with Drive. This is just an alias to the `upload` command that uploads specific files and includes a formatted argument.

```bash
$ parsley sync path_on_drive
```

## Installing

Parsley is written in Swift and requires the Swift toolchain. The easiest way if you're on macOS is to [download the latest version of Xcode](https://swift.org/download/#releases). 

Using the Swift Package Manager:

```bash
$ git clone https://github.com/Treehouse/Parsley.git
$ cd Parsley
$ swift build -c release -Xswiftc -static-stdlib
$ cp -f .build/release/Parsley /usr/local/bin/parsley
```

Using [Mint](https://github.com/yonaskolb/mint):

```bash
$ mint install Treehouse/Parsley
```

## Requirements

Parsley requires the following to be installed on your system:

- Swift 5.0 or later (bundled with Xcode 10.2 or later)
- Git

## Examples

Check out this [repository](https://github.com/treehouse/swift-content/tree/master/swift-basics-v4) for a few example course scripts written according to the TreehouseMarkdown spec.

## Architecture 

A bit about architecture for those who want to poke around. Parsley contains three modules:

**ParsleyCore**

All the logic for the CLI is in here. If you want to add new commands/aliases this is where you do it

**Syllablast** 

This module contains the definition of a Treehouse syllabus object along with the logic and associated objects to build one from a markdown abstract syntax tree.

The only time you'll want to modify the code in here is to add new steps (Video, Instruction etc) or substeps like quiz question types. 

If you're wondering about the name, it is a portmanteau of Syllabus and AST (you can thank @benjakuben for that). 

**SwiftMark**

A custom Markdown parser implemented in Swift that returns an abstract syntax tree of Markdown blocks. Unlike most markdown parsers SwiftMark doesn't care about rendering output or storing the parsed text. Since Parsley only cares about specific portions of the text depending on the command you execute (metadata if you generate admin.yml, or actual scripts if you generate production docs) the generated AST instead stores indexes or markers for every block. 

The spec for using Markdown to define a course and all its related information tries to stick to using established Markdown conventions (specifically Github Flavored Markdown) and not introduce any new "elements". If needed SwiftMark can be extended to support it. The parser does not rely on regular expressions however and instead creates tokens as characters are individually parsed.

If you have questions, open an issue as a feature request.

## Help, feedback or suggestions?

- Run `$ parsley --help` to display help for the tool itself or for any specific command.
- Open an issue if you need help, if you found a bug, or if you want to discuss a feature request.
- Open a PR if you want to make some change to Parsley.
- Get in touch with Pasan in Slack
