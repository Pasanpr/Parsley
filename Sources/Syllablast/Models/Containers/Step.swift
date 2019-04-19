//
//  Step.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

protocol Step {
    var title: String { get }
    var description: String { get }
    var accessLevel: AccessLevel { get }
    var published: Bool { get }
    var learningObjectives: [LearningObjective] { get }
}
