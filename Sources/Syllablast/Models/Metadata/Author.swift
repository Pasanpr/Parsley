//
//  Author.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

struct Author: Codable {
    let email: String
}

extension Author: Equatable {
    static func ==(lhs: Author, rhs: Author) -> Bool {
        return lhs.email == rhs.email
    }
}
