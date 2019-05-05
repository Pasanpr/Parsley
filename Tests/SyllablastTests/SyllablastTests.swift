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
    func quiz(_ n: Int, inStage stage: Int) -> Quiz {
        let syllabus = try! generateSyllabus()
        let stage = syllabus.course.stages[stage-1]
        let quizzes = stage.steps.compactMap({ $0.quiz })
        return quizzes[n-1]
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
        let path = Folder.current.path.contains("DerivedData") ? try! Folder(path: "/Users/pasan/Development/Parsley/test-files/syllablast/quizzes").path : try! Folder.current.subfolder(atPath: "test-files/syllablast/quizzes").path
        syllablast = try! Parsley.generateSyllablastFromScripts(at: path)
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
