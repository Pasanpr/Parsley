//
//  MarkdownParserCodec.swift
//  SwiftMark
//
//  Created by Pasan Premaratne on 4/19/19.
//

import Foundation

public protocol MarkdownParserCodec {
    associatedtype CodeUnit: Comparable
    
    static func fromASCII(_ character: UInt8) -> CodeUnit
    static func string<S>(fromTokens tokens: S) -> String where S: Sequence, S.Element == CodeUnit
    static func unicodeScalar(from token: CodeUnit) -> UnicodeScalar?
}

extension MarkdownParserCodec {
    static var linefeed   : CodeUnit { return Self.fromASCII(0x0A) }
    static var carriage   : CodeUnit { return Self.fromASCII(0x0D) }
    static var tab        : CodeUnit { return Self.fromASCII(0x09) }
    static var space      : CodeUnit { return Self.fromASCII(0x20) }
    static var exclammark : CodeUnit { return Self.fromASCII(0x21) }
    static var hash       : CodeUnit { return Self.fromASCII(0x23) }
    static var leftparen  : CodeUnit { return Self.fromASCII(0x28) }
    static var rightparen : CodeUnit { return Self.fromASCII(0x29) }
    static var asterisk   : CodeUnit { return Self.fromASCII(0x2A) }
    static var plus       : CodeUnit { return Self.fromASCII(0x2B) }
    static var hyphen     : CodeUnit { return Self.fromASCII(0x2D) }
    static var fullstop   : CodeUnit { return Self.fromASCII(0x2E) }
    static var zero       : CodeUnit { return Self.fromASCII(0x30) }
    static var nine       : CodeUnit { return Self.fromASCII(0x39) }
    static var colon      : CodeUnit { return Self.fromASCII(0x3A) }
    static var quote      : CodeUnit { return Self.fromASCII(0x3E) }
    static var leftsqbck  : CodeUnit { return Self.fromASCII(0x5B) }
    static var backslash  : CodeUnit { return Self.fromASCII(0x5C) }
    static var rightsqbck : CodeUnit { return Self.fromASCII(0x5D) }
    static var underscore : CodeUnit { return Self.fromASCII(0x5F) }
    static var backtick   : CodeUnit { return Self.fromASCII(0x60) }
    static var tilde      : CodeUnit { return Self.fromASCII(0x7E) }
}

private let asciiPunctuationTokens: [Bool] = {
    var map = Array(repeating: false, count: 128)
    let punctuationSigns = [
        0x21, 0x22, 0x23, 0x24,
        0x25, 0x26, 0x27, 0x28,
        0x29, 0x2A, 0x2B, 0x2C,
        0x2D, 0x2E, 0x2F, 0x3A,
        0x3B, 0x3C, 0x3D, 0x3E,
        0x3F, 0x40, 0x5B, 0x5C,
        0x5D, 0x5E, 0x5F, 0x60,
        0x7B, 0x7C, 0x7D, 0x7E,
    ]
    for codeUnit in punctuationSigns {
        map[codeUnit] = true
    }
    return map
}()

extension MarkdownParserCodec {
    public static func isPunctuation(_ token: CodeUnit) -> Bool {
        guard let scalar = unicodeScalar(from: token), scalar.value < 128 else {
            return false
        }
        
        return asciiPunctuationTokens[Int(scalar.value)]
    }
    
    static func digit(representedByToken token: CodeUnit) -> Int {
        let scalar = unicodeScalar(from: token)!
        return Int(scalar.value - 0x30)
    }
}

public enum UTF8MarkdownCodec: MarkdownParserCodec {
    public typealias CodeUnit = UInt8
    
    public static func unicodeScalar(from token: UInt8) -> UnicodeScalar? {
        return UnicodeScalar(token)
    }
    
    public static func fromASCII(_ character: UInt8) -> UInt8 {
        return character
    }
    
    public static func string<S>(fromTokens tokens: S) -> String where S : Sequence, UTF8MarkdownCodec.CodeUnit == S.Element {
        var utf8Decoder = UTF8()
        var scalars: [Unicode.Scalar] = []
        var bytesIterator = tokens.makeIterator()
        
        Decode: while true {
            switch utf8Decoder.decode(&bytesIterator) {
            case .scalarValue(let value):
                scalars.append(value)
            case .emptyInput: break Decode
            case .error:
                print("Decoding error")
                break Decode
            }
        }
        
        return String(String.UnicodeScalarView(scalars))
    }
}

public enum UTF16MarkdownCodec: MarkdownParserCodec {
    public typealias CodeUnit = UInt16
    
    public static func unicodeScalar(from token: UInt16) -> UnicodeScalar? {
        return UnicodeScalar(token)
    }
    
    public static func fromASCII(_ character: UInt8) -> UInt16 {
        return UInt16(character)
    }
    
    public static func string<S>(fromTokens tokens: S) -> String where S : Sequence, UTF16MarkdownCodec.CodeUnit == S.Element {
        var utf16Decoder = UTF16()
        var scalars: [Unicode.Scalar] = []
        var bytesIterator = tokens.makeIterator()
        
        Decode: while true {
            switch utf16Decoder.decode(&bytesIterator) {
            case .scalarValue(let value):
                scalars.append(value)
            case .emptyInput: break Decode
            case .error:
                print("Decoding error")
                break Decode
            }
        }
        
        return String(String.UnicodeScalarView(scalars))
    }
}

public enum UTF32MarkdownCodec: MarkdownParserCodec {
    public typealias CodeUnit = UInt32
    
    public static func unicodeScalar(from token: UInt32) -> UnicodeScalar? {
        return UnicodeScalar(token)
    }
    
    public static func fromASCII(_ character: UInt8) -> UInt32 {
        return UInt32(character)
    }
    
    public static func string<S>(fromTokens tokens: S) -> String where S : Sequence, UTF32MarkdownCodec.CodeUnit == S.Element {
        var utf32Decoder = UTF32()
        var scalars: [Unicode.Scalar] = []
        var bytesIterator = tokens.makeIterator()
        
        Decode: while true {
            switch utf32Decoder.decode(&bytesIterator) {
            case .scalarValue(let value):
                scalars.append(value)
            case .emptyInput: break Decode
            case .error:
                print("Decoding error")
                break Decode
            }
        }
        
        return String(String.UnicodeScalarView(scalars))
    }
}

public enum CharacterMarkdownCodec: MarkdownParserCodec {
    public typealias CodeUnit = Character
    
    public static func unicodeScalar(from token: Character) -> UnicodeScalar? {
        return token.unicodeScalars.first
    }
    
    public static func fromASCII(_ char: UInt8) -> Character {
        return Character(UnicodeScalar(char))
    }
    
    public static func string <S: Sequence> (fromTokens tokens: S) -> String
        where S.Element == CodeUnit
    {
        return String(tokens)
    }
}

public enum UnicodeScalarMarkdownCodec: MarkdownParserCodec {
    public typealias CodeUnit = UnicodeScalar
    
    public static func unicodeScalar(from token: UnicodeScalar) -> UnicodeScalar? {
        return token
    }
    
    public static func fromASCII(_ char: UInt8) -> UnicodeScalar {
        return UnicodeScalar(char)
    }
    
    public static func string <S: Sequence> (fromTokens tokens: S) -> String
        where S.Iterator.Element == CodeUnit
    {
        var s = ""
        s.unicodeScalars.append(contentsOf: tokens)
        return s
    }
}
