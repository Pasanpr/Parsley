//
//  Scanning.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

struct Scanner<Data> where Data: BidirectionalCollection {
    let data: Data
    var startIndex: Data.Index
    var endIndex: Data.Index
    
    init(data: Data, startIndex: Data.Index? = nil, endIndex: Data.Index? = nil) {
        self.data = data
        self.startIndex = startIndex ?? data.startIndex
        self.endIndex = endIndex ?? data.endIndex
    }
}

enum PopOrStop { case pop, stop }

extension Scanner {
    var indices: Range<Data.Index> { return startIndex..<endIndex }
    
    mutating func popWhile(_ predicate: (Data.Element?) throws -> PopOrStop) rethrows {
        var currentIndex = startIndex
        while currentIndex != endIndex, case .pop = try predicate(data[currentIndex])  {
            currentIndex = data.index(after: currentIndex)
        }
        
        if currentIndex == endIndex {
            _ = try predicate(nil)
        }
        
        startIndex = currentIndex
    }
    
    func peek() -> Data.Element? {
        guard startIndex != endIndex else {
            return nil
        }
        
        return data[startIndex]
    }
    
    mutating func pop() -> Data.Element? {
        guard startIndex != endIndex else {
            return nil
        }
        
        defer {
            startIndex = data.index(after: startIndex)
        }
        
        return data[startIndex]
    }
}

extension Scanner where Data.Element: Equatable {
    /// Pop elements from the scanner until reaching an element equal to `x`.
    /// The element equal to `x` won’t be popped.
    mutating func popUntil(_ x: Data.Element) {
        var currentIndex = startIndex
        
        while currentIndex != endIndex && data[currentIndex] != x {
            currentIndex = data.index(after: currentIndex)
        }
        
        startIndex = currentIndex
    }
    
    mutating func popWhile(_ x: Data.Element) {
        var currentIndex = startIndex
        
        while currentIndex != endIndex && data[currentIndex] == x {
            currentIndex = data.index(after: currentIndex)
        }
        
        startIndex = currentIndex
    }
    
    mutating func pop(_ x: Data.Element) -> Bool {
        guard startIndex != endIndex && data[startIndex] == x else {
            return false
        }
        defer {
            startIndex = data.index(after: startIndex)
        }
        return true
    }
    
    // Pop an element from the scanner if it is not equal to `x`.
    /// - returns: the element that was popped, `nil` otherwise
    mutating func pop(ifNot x: Data.Iterator.Element) -> Data.Iterator.Element? {
        guard startIndex != endIndex && data[startIndex] != x else {
            return nil
        }
        
        defer {
            startIndex = data.index(after: startIndex)
        }
        return data[startIndex]
    }
}
