## Treehouse Markdown

This document defines a spec for using Markdown to create a Treehouse course using Parsley. The spec is fairly rigid and this is largely due to an effort to automate some of the drudgery of course production. 

The spec is also limited to providing solutions to pain points defined in pre-production phase and therefore does not include project files, workspaces or other assets that are distributed to students. 

An example of a script that implements this format can be found [here](https://github.com/treehouse/swift-content/blob/master/swift-basics-v4/scripts/Stage-1.md)

## Possibilities

Before asking you to write your scripts this way, here's the why. Doing it this way you can automate the creation of:

- `admin.yml` file for course creation in Treehouse Admin
- Scripts (on set and full versions) formatted for and uploaded to Drive
- Learning Objective doc
- Teacher's Note docs

## File Structure and Naming Convention

Scripts should be organized in a `scripts` subdirectory. Inside the subdirectory you can either create a single `scripts.md` or you can split by stage. In case of the latter, name files according to the format `Stage-X.md`. 

## Frontmatter

Course level information is specified in a Jekyll style frontmatter block. If the scripts are split across several docs by stage, then specify frontmatter **only** in the `Stage-1.md` file. When scripts are split across files Parsley concatenates them into a single source doc and multiple blocks of frontmatter will result in an error.

Example:

```yaml
---
title: Swift Arrays
topic: Swift
description: |
In the past we've only worked with a single item of data in a constant or a variable. There's much more to this of course, and working with groups or collections of data is an important part of programming. In this course we'll look at the the first fundamental type that we use in Swift to represent these collections - Arrays
concepts_covered: |
Declaring array literals
Appending, inserting, updating and removing elements
For in loops"
status: New
skill_level: Beginner
access_level: Basic
estimated_publish_date: 2019-05-01
roadmap: false
responsible_teacher: pasan@teamtreehouse.com
```

## Headers for Structure

Headers are used to denote specific parts of the script. 

- Level 1: Stage  -  Stage Title. 

```md
# Stage - An Introduction to Programming
```

- Level 2: Individual step type - name

```md
## Video - What is Swift?

## Code Challenge - Working With Constants

## Instruction - Getting Set Up

## Quiz - Review: Strings
```
- Level 3: Recording Mode

```md
### On Set

### Screencast
```

Couple things to note:

- Use a hyphen between Identifier names (Stage, Video, etc) and the title
- Do not number steps (Video 1 - Foo). Numbering is handled by Parsley automatically.
- Inside of an Instruction step H3 and beyond are ignored since the markdown needs to be preserved. If you need an H1 or H2 header inside an Instruction step, use the [setext heading](https://github.github.com/gfm/#setext-heading) format

## Stage and Step Metadata

Admin requires metadata for every stage and step but this cannot be specified using a frontmatter block since this is expected as the first block in a markdown file. Instead use a yaml code block after any H2 to specify metadata for that step.

~~~md

## Video - For Loops

```yaml
---
description: This is a video description
```
~~~

Relevant keys and values are documented in the [Content YAML format](https://teamtreehouse.atlassian.net/wiki/spaces/CL/pages/216104968/Content+YAML+Format) section of the docs but Parsley provies some sane defaults

**Video**

- Only `description` needs to be defined. Defaults are provided for access level (Basic), published (false) and topic (parent topic)

**Instruction**

- Define `description`, and `format`. Estimated length is calculated automatically based on a reading speed of 200 wpm.

**Quiz**

- No metadata needed. Description is set to an empty string and total number of questions are calculated automatically 

**Code Challenge**

- No metadata needed.

## Script Metadata

Scripts contain other kinds of metadata - from learning objectives used for Compass, to motion, keynote and on set blocks for production. This section describes how to use markdown to encode such information into your scripts. To understand this section you will need to be familiar with [reference definitions](./ReferenceDefinition.md) in Markdown.

### Motion & Keynote

Both motion and keynote blocks are specified using shortcut reference definitions inline. Typically you need to supply the definition elsewhere in the document but Parsley knows not to look for these.

- Opening Tag: `[MOTION]`
- Closing Tag: `[/MOTION]`

- Opening Tag: `[KEYNOTE]`
- Closing Tag: `[/KEYNOTE]`

Scripts defined betwee these _tags_ can be output into a `motion.md` doc and each tag given an identifier to mark its place in the script. Example: `[MOTION: S1V1M1]` for the first motion segment in Video 1 of Stage 1. This is useful for recording audio scratch tracks or handing off to motion.

### Learning Objectives

Learning objectives are specified using shortcut ref defs and require both a link text inline and link label definitions at the bottom of the doc. The parser will only look for defined learning objectives at the bottom of the doc.

- Inline syntax: `[LO-X]`

The `X` represents an identifier. This identifier is used in quizzes to associate a video and learning objective with a quiz question (more on this later). Example:

`To create a string literal we enclose some text within a pair of double quotes [LO-36].`

At the bottom of the doc **after a thematic/line break** (this is really important!),  the full reference definition is defined to add more context. After the inline text, specify a colon along with the title of the Learning Objective. 

- `[LO-35]: Recall that text between double quotes is more formally called a string literal`

By default all LO tags are Level 1 (recall) tags. To specify otherwise follow the syntax `[LO-X-Y]` where X is the id as before and Y is either `2` for interpretation or `3` for synthesis.

- Inline: `[LO-36-2]`
- `[LO-36-2]: Create a string literal and assign it to a constant`

It is important that a thematic break (---) is included before the learning objectives are defined at the bottom of the document. Reference definitions are used in standard markdown to link to external resources/urls and by using a thematic break to signify the beginning of the Learning Objective section, Parsley can leave your regular links alone.

## Teacher's Notes

Teacher's Notes are a bit complicated (not as much as quizzes!) because any valid markdown is a valid note. Notes can span a single line or entire documents. To handle Parsley relies on the fact that Markdown specifies two types of code fence delimiters - the standard backticks (```), or tildes (~~~). 

To specify a teacher's note section use the `~~~` opening and closing delimiters. For example:

```
~~~
- [String](https://developer.apple.com/documentation/swift/string)
~~~
```

Everything between the `~~~` delimiters are included as is. The advantage of this is you can specify Notes inline as they are mentioned in the scripts (if you prefer that sort of thing). Since code fences need to be closed by the same style of delimiter as the opening this means you can add backtick style code fences inside of a notes block to format your code for  presentation.

The advantage of defining notes inline is that you won't forget anything. Often times however notes that are spread through out the document will need to be presented under one H4 in app. To account for this you can add a name to the notes block. To group the note specified above under an H4 named "Documentation":

```
~~~documentation
- [String](https://developer.apple.com/documentation/swift/string)
~~~
```

All notes blocks spread throughout a step with the name `documentation`  are collected and grouped together. For multiple worded titles use snake case. Titles will be created using title case. If you want to avoid this behavior you can simply define a single notes block per step formatted exactly how you want it presented. Since all valid markdown is accepted, you can create notes that look like this:

```
~~~navigating-directories

Use the `cd` command to _change directories_. After the command, specify the _path_ to the location you want to change to. For example, let's say your home directory is named "Mac" and you want to navigate to the folder located at Development > Swift > Basics, you would execute the command

`cd ~/Development/Swift/Basics`

The `~/` in that path (called the tilde symbol) is automatically expanded to your home directory.

You can check your current directory using the `pwd` command.

To learn more about navigating in the Terminal, check out the [Console Foundations Course](https://teamtreehouse.com/library/console-foundations).

~~~
```

## Quizzes

Specifying quizzes in a script doc is not easy. There are several types of quizzes each with a varying list of options, multiple answers and associated feedback. The following section introduces base quiz "blocks" and builds on top of it to include all types of quiz questions.   

At it's most basic a Quiz collection type is identified by specifying an H2 with the word Quiz as its step identifier. This tells the parser that inside it can find a series of fenced code blocks where each code block is a quiz question. To specify this explicitly use `quiz` as the language specifier on the code block.

~~~
```quiz
```
~~~

Inside each code block, the first line specifies the type of question along with all of its options using a format string. Format strings start with the `::` delimiter followed by the type of question:

- Multiple Choice: `::mc`
- Fill in the Blanks: `::fitb`
- True/False: `::tf`
- Multiple Choice Multiple Answer: `::mcma`

Just like Learning Objective reference definitions, these format strings allow for the specification of arguments.

### Multiple Choice

`::mc-true/false-*x`

Immediately following the type specifier either `true` or `false` is specified to correspond to the Shuffle Answers setting.

All quiz format specifiers end with `*x` where `x` is an integer specifying the LO id defined in an LO tag. In the resulting YAML doc the associations are made appropriately. For example if you defined a learning objective using the string `[LO-2]` anywhere in the scripts prior to the quiz step, you can use `*2` to associate a quiz question with said learning objective.

After the format string, all lines of text until an answer specifier are parsed as the question.

To specify answers, use the syntax:

`[A-1-true] let`

- `[A]` denotes an answer. 
- `1` here is an identifier used if feedback needs to be associated with the answer (example below)
- `true` indicates this is a correct answer
- `let` is the actual answer

This is an example of an incorrect answer with feedback associated:

```
[A-2] var
[F-2] Remember that var defines a variable
```

Here `2` is used as an ID so that the feedback can be matched to the answer. It's a more explicit convention than stating that feedback should immediately follow an answer. This way Parsley doesn't have to expect and search for feedback. Instead the `[F]` specifier inside a quiz code block indicates feedback. 

Putting this together a Multiple Choice block with its various options looks like this:

```
::mc-true-*18

Which of the following keywords declares a constant?

[A-true] let

[A-2] var
[F-2] Remember that var defines a variable

[A-3] const
[F-3] Const is a keyword used in other languages but not in Swift

[A] final
```

### Multiple Choice Multiple Answer

Exact same as above except the type specifier is `::mcma` and you can specify multiple answers as true. Example:

```
::mcma-true-*18

Which of the following keywords declares a constant?

[A-true] let

[A-2-true] var
[F-2] Remember that var defines a variable

[A-3] const
[F-3] Const is a keyword used in other languages but not in Swift

[A] final
```

### Fill In The Blanks

`::fitb-*x`

As mentioned previously `x` is an integer specifying the LO id defined in an LO tag.

Immediately after the format string, specify the FITB question. Any valid markdown, including HTML tags are accepted here. If you need markdown code fences then use the tilde style.

```
Fill in the blanks to create a multi line comment
<br>
<pre><code>
___ 
This is a multi line comment 
___
</code></pre>
```

Answers are specified using the `[A]` answer tag as specified earlier, but since in FITB questions each answer can include various options, these need to be specified as well. 

`[A-X-true/false-true/false]`

- `X` is the blank index
- The first argument after the hyphen sets "Uses String Validation" to true or false
- The second argument after the hyphen sets "Canonical" to true or false. 

Finally the actual answer is specified. Here is an example of one that sets string validation to false and canonical to true:

`[A-0-false-true] var`

Here is another example that sets string validation to true and canonical to false:

`[A-0-true-false] downcase | equals 'hello world'`

Putting this all together a Fill In the Blanks block looks like this:

```
::fitb-*34

Fill in the blanks to create a multi line comment
<br>
<pre><code>
___ 
This is a multi line comment 
___
</code></pre>


[A-0-false-true] /*
[A-1-false-true] */
```

### True or False

`::tf-true/false-*x`

The easiest type to specify, true false questions include the answer and the LO id in the format string. Immediately after the type specifier, indicate whether the answer has a True or False answer.

If you'd like to include feedback, you most certainly can. Unlike MC questions where feedback is associated with each possible answer, TF questions only accept two feedback options - one for true, one for false.

Feedback specifiers are therefore modified to use not IDs but `T` or `F` identifiers for true and false feedback respectively. 

Here is an example of feedback when the user selects False on a question where the answer is False:

`[F-F] You got that right!`

Similarly if the answer is False but the student selects True, feedback is specified as follows:

`[F-T] It happens the other way around! Data from the right side gets assigned to the constant on the left`

Putting this all together a True/False block looks like this

```
::tf-false-*22

The assignment operator assigns data from the left side to the constant on the right side

[F-F] You got that right!
[F-T] It happens the other way around! Data from the right side gets assigned to the constant on the left
```
