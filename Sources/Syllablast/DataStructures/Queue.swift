//
//  Queue.swift
//  Syllablast
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

/*
 First-in first-out queue (FIFO)
 
 New elements are added to the end of the queue. Dequeuing pulls elements from
 the front of the queue.
 
 Enqueuing and dequeuing are O(1) operations.
 */
public struct Queue<T> {
    fileprivate var array = [T?]()
    fileprivate var head = 0
    
    public var isEmpty: Bool {
        return count == 0
    }
    
    public var isNotEmpty: Bool {
        return !isEmpty
    }
    
    public var count: Int {
        return array.count - head
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    @discardableResult public mutating func dequeue() -> T? {
        guard head < array.count, let element = array[head] else { return nil }
        
        array[head] = nil
        head += 1
        
        let percentage = Double(head)/Double(array.count)
        if array.count > 50 && percentage > 0.25 {
            array.removeFirst(head)
            head = 0
        }
        
        return element
    }
    
    public var front: T? {
        if isEmpty {
            return nil
        } else {
            return array[head]
        }
    }
}

public struct QueueIterator<T>: IteratorProtocol {
    var currentQueue: Queue<T>
    var currentIndex = 0
    
    init(queue: Queue<T>) {
        self.currentQueue = queue
    }
    
    public mutating func next() -> T? {
        let element = currentQueue.peek(by: currentIndex)
        currentIndex += 1
        return element
    }
}

extension Queue: Sequence {
    public func makeIterator() -> QueueIterator<T> {
        return QueueIterator(queue: self)
    }
}

extension Queue: CustomStringConvertible {
    public var description: String {
        return array.description
    }
}

enum PopOrStop {
    case pop, stop
}

extension Queue {
    public func peek() -> T? {
        return peek(by: 0)
    }
    
    public func peek(by n: Int) -> T? {
        guard head + n < array.count, let element = array[head + n] else { return nil }
        return element
    }
    
    mutating func dequeueWhile(_ predicate: (T?) throws -> PopOrStop) rethrows -> Queue<T> {
        var newQueue = Queue<T>()
        while !isEmpty, case .pop = try predicate(peek()) {
            newQueue.enqueue(dequeue()!)
        }
        
        return newQueue
    }
}
