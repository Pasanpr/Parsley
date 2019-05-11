import XCTest
import ParsleyCore
import Files
import SwiftMark
@testable import Syllablast

fileprivate extension MultipleChoiceQuestion {
    static var testCase: MultipleChoiceQuestion {
        let testQuestion = """
        Which of the following lines of code would result in the output shown below:
        <br>
        <pre><code>
        Good morning!
        It is 75 degrees today.
        </code><pre>
        """
        
        let learningObjective = LearningObjective(id: 1, parent: nil, title: "Recall that a collection is a structure that contains multiple values", cognitiveLevel: .recall, topic: .swift)
        
        let answers: [MultipleChoiceAnswer] = [
            MultipleChoiceAnswer(id: "1", answer: "\"Good morning!\" + \"\\n\" + \"It is 75 degrees today.\"", isCorrect: true, feedback: "Test feedback!"),
            MultipleChoiceAnswer(id: "2", answer: "\"Good morning!\" + \"\\t\" + \"It is 75 degrees today.\"", isCorrect: false),
            MultipleChoiceAnswer(id: "3", answer: "\"Good morning!\" + \"\\r\" + \"It is 75 degrees today.\"", isCorrect: false)
        ]
        
        return MultipleChoiceQuestion(question: testQuestion, associatedLearningObjective: learningObjective, shuffleAnswers: true, answers: answers, canSelectMultipleAnswers: false)
    }
    
    static var selectAllTestCase: MultipleChoiceQuestion {
        let testQuestion = """
        Which of the following lines of code would result in the output shown below:
        <br>
        <pre><code>
        Good morning!
        It is 75 degrees today.
        </code><pre>
        """
        
        let learningObjective = LearningObjective(id: 1, parent: nil, title: "Recall that a collection is a structure that contains multiple values", cognitiveLevel: .recall, topic: .swift)
        
        let answers: [MultipleChoiceAnswer] = [
            MultipleChoiceAnswer(id: "1", answer: "\"Good morning!\" + \"\\n\" + \"It is 75 degrees today.\"", isCorrect: true, feedback: "Test feedback!"),
            MultipleChoiceAnswer(id: "2", answer: "\"Good morning!\" + \"\\t\" + \"It is 75 degrees today.\"", isCorrect: true),
            MultipleChoiceAnswer(id: "3", answer: "\"Good morning!\" + \"\\r\" + \"It is 75 degrees today.\"", isCorrect: true)
        ]
        
        return MultipleChoiceQuestion(question: testQuestion, associatedLearningObjective: learningObjective, shuffleAnswers: true, answers: answers, canSelectMultipleAnswers: true)
    }
}

fileprivate extension FillInTheBlankQuestion {
    static var testCase: FillInTheBlankQuestion {
        let learningObjective = LearningObjective(id: 1, parent: nil, title: "Recall that a collection is a structure that contains multiple values", cognitiveLevel: .recall, topic: .swift)
        
        let testQuestion = """
        Fill in the blank to complete the while loop defined below:
        ~~~
        var counter = 0

        ___ counter < 10 {
            print(counter)
            counter += 1
        }
        ~~~
        """
        
        let answers: [FillInTheBlankAnswer] = [
            FillInTheBlankAnswer(id: nil, blankIndex: 0, answer: "while", usesStringValidation: false, isCanonical: true)
        ]
        
        return FillInTheBlankQuestion(question: testQuestion, associatedLearningObjective: learningObjective, answers: answers)
    }
}

fileprivate extension TrueFalseQuestion {
    static var testCase: TrueFalseQuestion {
        let learningObjective = LearningObjective(id: 1, parent: nil, title: "Recall that a collection is a structure that contains multiple values", cognitiveLevel: .recall, topic: .swift)
        
        return TrueFalseQuestion(question: "This is a true false question", associatedLearningObjective: learningObjective, answer: true, trueFeedback: "This is true feedback", falseFeedback: "This is false feedback")
    }
}

extension Syllablast {
    func stage(n: Int) -> Stage<View, DefinitionStore.Definition, Codec> {
        let syllabus = try! generateSyllabus()
        return syllabus.course.stages[n-1]
    }
    
    func video(_ n: Int, inStage stage: Int) -> Video<View, DefinitionStore.Definition> {
        let stage = self.stage(n: stage)
        let videos = stage.steps.compactMap({ $0.video })
        return videos[n-1]
    }
    
    func quiz(_ n: Int, inStage stage: Int) -> Quiz {
        let stage = self.stage(n: stage)
        let quizzes = stage.steps.compactMap({ $0.quiz })
        return quizzes[n-1]
    }
    
    func instruction(_ n: Int, inStage stage: Int) -> Instruction<View, DefinitionStore.Definition> {
        let stage = self.stage(n: stage)
        let instructions = stage.steps.compactMap({ $0.instruction })
        return instructions[n-1]
    }
}

extension QuizQuestion {
    var multipleChoiceQuestion: MultipleChoiceQuestion? {
        switch self {
        case .multipleChoice(let question): return question
        default: return nil
        }
    }
    
    var fillInTheBlankQuestion: FillInTheBlankQuestion? {
        switch self {
        case .fitb(let question): return question
        default: return nil
        }
    }
    
    var trueFalseQuestion: TrueFalseQuestion? {
        switch self {
        case .trueFalse(let question): return question
        default: return nil
        }
    }
    
    var multipleChoiceMultipleAnswerQuestion: MultipleChoiceQuestion? {
        switch self {
        case .multipleChoiceMultipleAnswer(let question): return question
        default: return nil
        }
    }
}

extension Array where Element == QuizQuestion {
    var multipleChoiceQuestions: [MultipleChoiceQuestion] {
        return self.compactMap({ $0.multipleChoiceQuestion })
    }
    
    var fillInTheBlankQuestions: [FillInTheBlankQuestion] {
        return self.compactMap({ $0.fillInTheBlankQuestion })
    }
    
    var trueFalseQuestions: [TrueFalseQuestion] {
        return self.compactMap({ $0.trueFalseQuestion })
    }
    
    var multipleChoiceMultipleAnswerQuestions: [MultipleChoiceQuestion] {
        return self.compactMap({ $0.multipleChoiceMultipleAnswerQuestion })
    }
}

final class SyllablastTests: XCTestCase {
    
    var syllablast: Syllablast<String, DefaultReferenceDefinitionStore, CharacterMarkdownCodec>!
    
    override func setUp() {
        let path = Folder.current.path.contains("DerivedData") ? try! Folder(path: "/Users/pasan/Development/Parsley/test-files/syllablast").path : try! Folder.current.subfolder(atPath: "test-files/syllablast").path
        syllablast = try! Parsley.generateSyllablastFromScripts(at: path)
    }
    
    func testSyllabus() {
        let course = try! syllablast.generateSyllabus().course
        XCTAssertEqual(course.title, "Swift Arrays")
        XCTAssertEqual(course.topic, .swift)
        
        let description = "In the past we've only worked with a single item of data in a constant or a variable. There's much more to this of course, and working with groups or collections of data is an important part of programming. In this course we'll look at the the first fundamental type that we use in Swift to represent these collections - Arrays"
        XCTAssertEqual(course.courseDescription, description)
        
        XCTAssertEqual(course.conceptsCovered, "Declaring array literals\nAppending, inserting, updating and removing elements\nFor in loops")
        XCTAssertEqual(course.status, .new)
        XCTAssertEqual(course.skillLevel, .beginner)
        XCTAssertEqual(course.accessLevel, .basic)
        XCTAssertEqual(course.estimatedPublishDate, "2019-05-01")
        XCTAssertEqual(course.isVisibleOnRoadmap, false)
        XCTAssertEqual(course.responsibleTeacher, "pasan@teamtreehouse.com")
    }
    
    func testStageStructureAndContents() {
        let stage = syllablast.stage(n: 1)
        
        XCTAssertEqual(stage.title, "Storing Data Sequentially")
        XCTAssertEqual(stage.description, "Arrays are one of many different collection types in Swift. Let\'s start by understanding what arrays are and take a look at the syntax used to create them\n")
        XCTAssertEqual(stage.topicsCovered, ["Array basics", "Declaring array literals", "Defining array types"])
        XCTAssertTrue(stage.steps.count == 3)
        
        XCTAssertTrue(stage.steps.first!.isVideo)
        XCTAssertTrue(stage.steps[1].isInstruction)
        XCTAssertTrue(stage.steps[2].isQuiz)
    }
    
    func testVideo() {
        let video = syllablast.video(1, inStage: 1)
        
        XCTAssertEqual(video.title, "Lists of Data")
        XCTAssertEqual(video.description, "In Swift the Array type is used to represent lists of data. In this video lets talk about what an array is and how we create array literals")
        XCTAssertEqual(video.accessLevel, .basic)
        XCTAssertEqual(video.published, false)
        
        let learningObjective = LearningObjective(id: 1, parent: video, title: "Recall that a collection is a structure that contains multiple values", cognitiveLevel: .recall, topic: .swift)
        XCTAssertTrue(video.learningObjectives.contains(learningObjective))
    }
    
    func testInstruction() {
        let instruction = syllablast.instruction(1, inStage: 1)
        XCTAssertEqual(instruction.format, InstructionFormat.markdown)
        XCTAssertEqual(instruction.description, "Let\'s recap everything we\'ve learned about the String type so far")
    }
    
    func testQuizzes() {
        let quiz = syllablast.quiz(1, inStage: 1)
        
        // Multiple Choice
        let multipleChoiceQuestions = quiz.questions.multipleChoiceQuestions
        let firstQuestion = multipleChoiceQuestions[0]
        XCTAssertEqual(firstQuestion, MultipleChoiceQuestion.testCase)
        
        // Multiple Choice Multiple Answers
        let multipleChoiceMultipleAnswerQuestions = quiz.questions.multipleChoiceMultipleAnswerQuestions
        let mcmaQuestion = multipleChoiceMultipleAnswerQuestions[0]
        XCTAssertEqual(mcmaQuestion, MultipleChoiceQuestion.selectAllTestCase)
        
        // FITB
        let fitbQuestions = quiz.questions.fillInTheBlankQuestions
        let fitbQuestion = fitbQuestions[0]
        XCTAssertEqual(fitbQuestion, FillInTheBlankQuestion.testCase)
        
        // True False
        let tfQuestions = quiz.questions.trueFalseQuestions
        let tfQuestion = tfQuestions[0]
        XCTAssertEqual(tfQuestion, TrueFalseQuestion.testCase)
    }
}
