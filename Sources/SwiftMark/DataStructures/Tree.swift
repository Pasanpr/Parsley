//
//  Tree.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

struct DepthLevel {
    fileprivate var _level: Int
    
    static var root: DepthLevel {
        return .init(0)
    }
    
    private init(_ level: Int) {
        self._level = level
    }
    
    func incremented() -> DepthLevel {
        return .init(_level + 1)
    }
    
    func decremented() -> DepthLevel {
        return .init(_level - 1)
    }
}

fileprivate struct TreeNode<T> {
    let data: T
    var end: Int
    
    init(data: T, end: Tree<T>.Buffer.Index) {
        self.data = data
        self.end = end
    }
}

final class Tree<T> {
    fileprivate typealias Buffer = ContiguousArray<TreeNode<T>>
    
    fileprivate var buffer: Buffer = []
    fileprivate var lastStrand: [Buffer.Index] = []
    
    var lastLeaf: T {
        return buffer[buffer.endIndex - 1].data
    }
    
    init() {}
    
    func last(depthLevel: DepthLevel) -> T? {
        guard lastStrand.indices.contains(depthLevel._level) else { return nil }
        return buffer[lastStrand[depthLevel._level]].data
    }
    
    func append(_ data: T, depthLevel level: DepthLevel) {
        let node = TreeNode(data: data, end: buffer.endIndex - 1)
        buffer.append(node)
        repairStructure(addedStrandLength: 1, level: level)
    }
    
    fileprivate func repairStructure(addedStrandLength: Int, level: DepthLevel) {
        lastStrand.removeSubrange(level._level ..< lastStrand.endIndex)
        lastStrand.append(contentsOf: (buffer.endIndex - addedStrandLength) ..< buffer.endIndex)
        
        for i in lastStrand {
            buffer[i].end += addedStrandLength
        }
    }
    
    func makePreOrderIterator() -> UnfoldSequence<T, Int> {
        return sequence(state: buffer.startIndex) { (idx: inout Int) -> T?  in
            defer { idx += 1 }
            return idx < self.buffer.endIndex ? self.buffer[idx].data : nil
        }
    }
    
    func makeBreadthFirstIterator() -> TreeBreadthFirstIterator<T> {
        return .init(self)
    }
    
}

struct TreeBreadthFirstIterator<T>: IteratorProtocol, Sequence {
    private typealias Buffer = Tree<T>.Buffer
    
    private let tree: Tree<T>
    
    private let endIndex: Buffer.Index
    private var index: Buffer.Index
    
    fileprivate init(_ tree: Tree<T>) {
        self.tree = tree
        self.endIndex = tree.buffer.endIndex
        self.index = 0
    }
    
    private init(_ tree: Tree<T>, startIndex: Buffer.Index, endIndex: Buffer.Index) {
        self.tree = tree
        self.index = startIndex
        self.endIndex = endIndex
    }
    
    mutating func next() -> (T, TreeBreadthFirstIterator?)? {
        guard index < endIndex else {
            return nil
        }
        
        let node = tree.buffer[index]
        
        defer {
            index = node.end + 1
        }
        
        return (node.data, diving())
    }
    
    private func diving() -> TreeBreadthFirstIterator? {
        assert(index < tree.buffer.endIndex)
        
        let end = tree.buffer[index].end
        
        guard index.distance(to: end) > 0 else {
            return nil
        }
        
        return TreeBreadthFirstIterator(tree, startIndex: index + 1, endIndex: end + 1)
    }
    
    func makeIterator() -> TreeBreadthFirstIterator<T> {
        return self
    }
}

extension MarkdownParser {
    private func appendStrand(line: Line, previousEnd: Tree<Block>.Buffer.Index) {
        func append(_ block: Block) {
            blockTree.buffer.append(.init(data: block, end: previousEnd))
        }
        
        guard line.indent.length < TAB_INDENT else {
            var newLine = line
            newLine.indent.length -= TAB_INDENT
            restoreIndentInLine(&newLine)
            append(.code(.init(text: [newLine.indices], trailingEmptyLines: [])))
            return
        }
        
        switch line.kind {
            
        case .quote(let rest):
            append(.quote(.init(firstMarker: line.indices.lowerBound)))
            appendStrand(line: rest, previousEnd: previousEnd)
            
        case .text:
            append(.paragraph(.init(text: [line.indices])))
            
        case .header(let text, let level):
            let startHashes = line.indices.lowerBound ..< view.index(line.indices.lowerBound, offsetBy: numericCast(level))
            let endHashes: Range<View.Index>? = {
                let temp = text.upperBound ..< line.indices.upperBound
                return temp.isEmpty ? nil : temp
            }()
            
            append(.header(.init(markers: (startHashes, endHashes), text: text, level: level)))
            
        case .list(let kind, let rest):
            let state: ListState = rest.kind.isEmpty ? .followedByEmptyLine : .normal
            
            let markerSpan = line.indices.lowerBound ..< view.index(line.indices.lowerBound, offsetBy: numericCast(kind.width))
            
            let list = ListNode<View>(kind: kind, state: state)
            let item = ListItemNode<View>(markerSpan: markerSpan)
            
            append(.list(list))
            append(.listItem(item))
            
            list.minimumIndent = line.indent.length + kind.width + rest.indent.length + 1
            
            guard !rest.kind.isEmpty else {
                return
            }
            
            let nextNodeIndex = blockTree.buffer.endIndex
            appendStrand(line: rest, previousEnd: previousEnd)
            
            if case .code = blockTree.buffer[nextNodeIndex].data {
                list.minimumIndent = line.indent.length + kind.width + 1
            }
            
        case .fence(let kind, let name, let level):
            let startMarker = line.indices.lowerBound ..< view.index(line.indices.lowerBound, offsetBy: numericCast(level))
            append(.fence(.init(kind: kind, startMarker: startMarker, name: name, text: [], level: level, indent: line.indent.length)))
            
        case .thematicBreak:
            append(.thematicBreak(.init(span: line.indices)))
            
        case .empty:
            append(.paragraph(.init(text: [])))
            
        case .reference(let title, let definition):
            append(.referenceDefinition(.init(title: title, definition: definition)))
        }
    }
    
    func appendStrand(from line: Line, level: DepthLevel) {
        let prevCount = blockTree.buffer.count
        appendStrand(line: line, previousEnd: prevCount - 1)
        let currentCount = blockTree.buffer.count
        blockTree.repairStructure(addedStrandLength: prevCount.distance(to: currentCount), level: level)
    }
}
