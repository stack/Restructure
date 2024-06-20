//
//  StatementEncoder.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/10/18.
//  Copyright @ 2020 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import SQLite3

// MARK: - StatementEncoder

/// `StatementEncoder` facilitates the encoding of `Encodable` values for a `Statement`.
public class StatementEncoder {
    
    // MARK: - Initialization
    
    /// Initializes `self` with the default strategies.
    public init() {}
    
    // MARK: - Encoding

    /// Encodes an Encodable to a Statement.
    ///
    /// - Parameter value: The `Encodable` to to encode to a statement.
    /// - Parameter to: The `Statement` to encode to.
    ///
    /// - Throws: `Error` if the encoding cannot happen.
    public func encode<T: Encodable>(_ value: T, to statement: Statement) throws {
        let encoder = _StatementEncoder(statement: statement)
        try value.encode(to: encoder)
    }
}


// MARK: - _StatementEncoder

fileprivate struct _StatementEncoder: Encoder {
    
    // MARK: - Properties
    
    fileprivate var codingPath: [CodingKey]
    fileprivate let statement: Statement
    fileprivate var userInfo: [CodingUserInfoKey : Any] = [:]
    
    // MARK: - Initialization
    
    fileprivate init(statement: Statement, codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
        self.statement = statement
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = _StatementEncodingContainer<Key>(referencing: self, codingPath: codingPath, wrapping: statement)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // TODO: Implement
        fatalError("Not Implemented")
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

extension _StatementEncoder: SingleValueEncodingContainer {
    mutating func encodeNil() throws {
        let key = codingPath.last!
        statement.bind(value: nil, for: key.stringValue)
    }
    
    mutating func encode(_ value: Bool) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: String) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: Double) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: Float) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: Int) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: Int8) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: Int16) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: Int32) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: Int64) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: UInt) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: UInt8) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: UInt16) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: UInt32) throws {
        let key = codingPath.last!
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encode(_ value: UInt64) throws {
        throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Encoding UInt64 is not supported"))
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Encoding \(value) is not supported"))
    }
    
    
}

// MARK: - Encoding Containers

fileprivate struct _StatementEncodingContainer<K : CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K
    
    // MARK: - Properties
    
    fileprivate let codingPath: [CodingKey]
    private var encoder: _StatementEncoder
    private let statement: Statement
    
    // MARK: - Initialization
    
    fileprivate init(referencing encoder: _StatementEncoder, codingPath: [CodingKey], wrapping statement: Statement) {
        self.codingPath = codingPath
        self.encoder = encoder
        self.statement = statement
    }
    
    mutating func encodeNil(forKey key: K) throws {
        statement.bind(value: nil, for: key.stringValue)
    }
    
    mutating func encode(_ value: Bool, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: Bool?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: String, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: String?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: Double, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: Double?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: Float, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: Float?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: Int, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: Int?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: Int8, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: Int8?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: Int16, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: Int16?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: Int32, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: Int32?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: Int64, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: Int64?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: UInt, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: UInt?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: UInt8, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: UInt8?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: UInt16, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: UInt16?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: UInt32, forKey key: K) throws {
        statement.bind(value: value, for: key.stringValue)
    }
    
    mutating func encodeIfPresent(_ value: UInt32?, forKey key: K) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode(_ value: UInt64, forKey key: K) throws {
        throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Encoding UInt64 is not supported"))
    }
    
    mutating func encodeIfPresent(_ value: UInt64?, forKey key: K) throws {
        if let value {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Encoding UInt64 is not supported"))
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        if let structurable = value as? Structurable {
            statement.bind(value: structurable, for: key.stringValue)
        } else {
            encoder.codingPath.append(key)
            defer { encoder.codingPath.removeLast() }
            try! value.encode(to: self.encoder)
            // throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Encoding \(value) is not supported"))
        }
    }
    
    mutating func encodeIfPresent<T>(_ value: T?, forKey key: K) throws where T : Encodable {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Not Implemented")
    }
    
    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        fatalError("Not Implemented")
    }
    
    mutating func superEncoder() -> Encoder {
        fatalError("Not Implemented")
    }
    
    mutating func superEncoder(forKey key: K) -> Encoder {
        fatalError("Not Implemented")
    }
}
