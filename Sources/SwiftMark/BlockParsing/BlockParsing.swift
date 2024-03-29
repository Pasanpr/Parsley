//
//  BlockParsing.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

enum ListState {
    case normal, followedByEmptyLine, closed, lastLeafIsCodeBlock
}

enum AddLineResult {
    case success
    case failure
}

extension MarkdownParser {
    func parseBlocks() {
        var scanner = Scanner(data: view)
        
        while case .some = scanner.peek() {
            _ = add(line: MarkdownParser.parseLine(&scanner, context: .default))
            // TODO: handle different line endings than LF
            scanner.popUntil(Codec.linefeed)
            _ = scanner.pop(Codec.linefeed)
        }
    }
    
    func updateDefinitionStore() {
        for case .referenceDefinition(let ref) in blockTree.makePreOrderIterator() {
            let title = Codec.string(fromTokens: view[ref.title])
            definitionStore.add(key: title, value: Codec.string(fromTokens: view[ref.definition]))
        }
    }
}

extension BlockNode {
    /**
     A lazy continuation happens when a new line of text is added to a Block
     without having to meet the usual criteria.
     
     Example:
     ```
     > # This is a header inside a quote
     This line is not part of the quote.
     
     > This is a paragraph inside a quote
     with a lazy continuation
     ```
     Here, the last line is not prefix with “>” and would normally not be
     added to the quote. However, it was allowed inside the quote because
     the last child of the quote was an open paragraph.
     
     `allowsLazyContinuation()` return true iff the block allows a lazy
     continuation when it is the last leaf of the blockTree.
     */
    func allowsLazyContinuation() -> Bool {
        if case .paragraph(let p) = self , !p.closed {
            return true
        } else {
            return false
        }
    }
}

extension MarkdownParser {
    fileprivate func add(line: Line) {
        let last = blockTree.last(depthLevel: .root)
        let addResult = last.map { add(line: line, to: $0, depthLevel: .root)} ?? .failure
        
        if case .failure = addResult, !line.kind.isEmpty {
            _ = appendStrand(from: line, level: .root)
        }
    }
    
    fileprivate func add(line: Line, to block: Block, depthLevel: DepthLevel) -> AddLineResult {
        switch block {
        case .paragraph(let x):
            return add(line: line, to: x)
        case .header:
            return .failure
        case .quote(let x):
            return add(line: line, to: x, quoteLevel: depthLevel)
        case .code(let x):
            return add(line: line, to: x)
        case .fence(let x):
            return add(line: line, to: x)
        case .list(let x):
            return add(line: line, to: x, listLevel: depthLevel)
        case .thematicBreak:
            return .failure
        case .referenceDefinition:
            return .failure
        case .listItem:
            fatalError()
        }
    }
}

// MARK: - Paragraph
extension MarkdownParser {
    fileprivate func add(line: Line, to paragraph: ParagraphNode<View>) -> AddLineResult {
        guard !paragraph.closed else { return .failure }
        
        switch line.kind {
        case .text, .reference:
            paragraph.text.append(line.indices)
            
        case .empty:
            paragraph.closed = true
            
        default:
            guard line.indent.length >= TAB_INDENT else { return .failure }
            var line = line
            line.indent.length -= TAB_INDENT
            paragraph.text.append(line.indices)
        }
        
        return .success
    }
}

// MARK: - Quote Block
extension MarkdownParser {
    fileprivate func directlyAddLine(line: Line, to quote: QuoteNode<View>, quoteLevel: DepthLevel) {
        let quoteContentLevel = quoteLevel.incremented()
        let last = blockTree.last(depthLevel: quoteContentLevel)!
        
        if case .failure = add(line: line, to: last, depthLevel: quoteContentLevel) {
            guard !line.kind.isEmpty else { return }
            appendStrand(from: line, level: quoteContentLevel)
        }
    }
    
    fileprivate func add(line: Line, to quote: QuoteNode<View>, quoteLevel: DepthLevel) -> AddLineResult {
        guard !quote.closed else { return .failure }
        
        let lastLeafAllowsLazyContinuation = blockTree.lastLeaf.allowsLazyContinuation()
        
        guard !(line.indent.length >= TAB_INDENT && lastLeafAllowsLazyContinuation) else {
            directlyAddLine(line: Line(.text, line.indent, line.indices), to: quote, quoteLevel: quoteLevel)
            return .success
        }
        
        switch line.kind {
            
        case .empty:
            quote.closed = true
            
        case .quote(let rest):
            quote.markers.append(line.indices.lowerBound)
            directlyAddLine(line: rest, to: quote, quoteLevel: quoteLevel)
            
        case .text:
            guard lastLeafAllowsLazyContinuation else {
                return .failure
            }
            directlyAddLine(line: line, to: quote, quoteLevel: quoteLevel)
            
        default:
            return .failure
        }
        return .success
    }
}

// MARK: - List
extension MarkdownParser {
    fileprivate func preparedLine(from initialLine: Line, for list: ListNode<View>) -> Line? {
        var line = initialLine
        guard !initialLine.kind.isEmpty else {
            return line
        }
        
        guard list.state != .closed else {
            return nil
        }
        
        let lastLeafAllowsLazyContinuation = blockTree.lastLeaf.allowsLazyContinuation()
        guard !(initialLine.indent.length >= list.minimumIndent + TAB_INDENT && lastLeafAllowsLazyContinuation) else {
            line.indent.length -= list.minimumIndent
            return line
        }
        
        line.indent.length -= list.minimumIndent
        let isWellIndented = line.indent.length >= 0
        
        switch line.kind {
            
        case .text:
            return isWellIndented || (list.state == .normal && lastLeafAllowsLazyContinuation) ? line : nil
            
        case let .list(k, _):
            if isWellIndented {
                return line
            } else {
                return k ~= list.kind ? line : nil
            }
            
        case .quote, .header, .fence, .reference:
            return isWellIndented ? line : nil
            
        default:
            return nil
        }
    }
    
    fileprivate func addPreparedLine(_ preparedLine: Line, to list: ListNode<View>, listLevel: DepthLevel) {
        switch preparedLine.kind {
        case .empty:
            switch list.state {
            case .lastLeafIsCodeBlock:
                // optimization to avoid deeply nested list + fence + empty lines worst case scenario
                let lastLeaf = blockTree.lastLeaf
                switch lastLeaf {
                case .code(let c): _ = add(line: preparedLine, to: c)
                case .fence(let f): _ = add(line: preparedLine, to: f)
                default:
                    fatalError()
                }
                
            case .normal:
                let itemContentLevel = listLevel.incremented().incremented()
                let lastItemContent = blockTree.last(depthLevel: itemContentLevel)
                
                let result = lastItemContent.map { add(line: preparedLine, to: $0, depthLevel: itemContentLevel) } ?? .failure
                
                let lastLeaf = blockTree.lastLeaf
                
                switch lastLeaf {
                case .fence, .code:
                    list.state = .lastLeafIsCodeBlock
                default:
                    switch result {
                    case .success: list.state = list.state == .normal  ? .followedByEmptyLine : .closed
                    case .failure: list.state = .closed
                    }
                }
                
            case .followedByEmptyLine:
                list.state = .closed
            case .closed:
                break
            }
            
        case .list(let kind, let rest) where preparedLine.indent.length < 0:
            list.state = .normal
            list.minimumIndent += preparedLine.indent.length + kind.width + 1
            let indices = preparedLine.indices
            let markerSpan = indices.lowerBound ..< view.index(indices.lowerBound, offsetBy: numericCast(kind.width))
            
            if case .empty = rest.kind {
                _ = blockTree.append(.listItem(.init(markerSpan: markerSpan)), depthLevel: listLevel.incremented())
            } else {
                let listItemLevel = listLevel.incremented()
                blockTree.append(.listItem(.init(markerSpan: markerSpan)), depthLevel: listItemLevel)
                appendStrand(from: rest, level: listItemLevel.incremented())
            }
            
        default:
            list.state = .normal
            let itemContentLevel = listLevel.incremented().incremented()
            let lastItemContent = blockTree.last(depthLevel: itemContentLevel)
            
            let addResult = lastItemContent.map { add(line: preparedLine, to: $0, depthLevel: itemContentLevel) } ?? .failure
            
            if case .failure = addResult {
                appendStrand(from: preparedLine, level: itemContentLevel)
            }
        }
    }
    
    fileprivate func add(line: Line, to list: ListNode<View>, listLevel: DepthLevel) -> AddLineResult {
        guard let line = preparedLine(from: line, for: list) else {
            return .failure
        }
        
        addPreparedLine(line, to: list, listLevel: listLevel)
        return .success
    }
}

// MARK: - Code Block
extension MarkdownParser {
    fileprivate func add(line: Line, to code: CodeNode<View>) -> AddLineResult {
        switch line.kind {
            
        case .empty:
            var line = line
            line.indent.length -= TAB_INDENT
            restoreIndentInLine(&line)
            code.trailingEmptyLines.append(line.indices)
            
        case _ where line.indent.length >= TAB_INDENT:
            var line = line
            line.indent.length -= TAB_INDENT
            restoreIndentInLine(&line)
            
            code.text.append(contentsOf: code.trailingEmptyLines)
            code.text.append(line.indices)
            code.trailingEmptyLines.removeAll()
            
        default:
            return .failure
        }
        return .success
    }
}

// MARK: - Fenced Code Block
extension MarkdownParser {
    fileprivate func add(line: Line, to fence: FenceNode<View>) -> AddLineResult {
        guard line.indent.length >= 0 && !fence.closed else {
            return .failure
        }
        
        var line = line
        line.indent.length -= fence.indent
        restoreIndentInLine(&line)
        
        switch line.kind {
        case .fence(fence.kind, let lineFenceName, let lineFenceLevel) where line.indent.length < TAB_INDENT && lineFenceName.isEmpty && lineFenceLevel >= fence.level:
            fence.markers.1 = line.indices
            fence.closed = true
            
        default:
            fence.text.append(line.indices)
        }
        
        return .success
    }
}
