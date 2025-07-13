//
//  StatementEncoder.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2018-11-10.
//  SPDX-License-Identifier: MIT
//

import Foundation
import SQLite3

// MARK: - StatementEncoder

/// `StatementEncoder` facilitates the encoding of `Encodable` values for a `Statement`.
public class StatementEncoder {

    // MARK: - Initialization

    /// Initializes `self` with the default strategies.
    public init() {
        // NOTE: Empty initializer for public consumption
    }

    // MARK: - Encoding

    /// Encodes an Encodable to a Statement.
    ///
    /// - Parameter value: The `Encodable` to to encode to a statement.
    /// - Parameter to: The `Statement` to encode to.
    ///
    /// - Throws: `Error` if the encoding cannot happen.
    public func encode<T: Encodable>(_ value: T, to statement: Statement) throws {
        let encoder = InnerStatementEncoder(statement: statement)
        try value.encode(to: encoder)
    }
}

// MARK: - InnerStatementEncoder

struct InnerStatementEncoder: Encoder {

    // MARK: - Properties

    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any] = [:]

    private let statement: Statement

    // MARK: - Initialization

    init(statement: Statement, codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
        self.statement = statement
    }

    func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = InnerStatementEncodingContainer<Key>(referencing: self, codingPath: codingPath, wrapping: statement)
        return KeyedEncodingContainer(container)
    }

    // swiftlint:disable unavailable_function
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Not Implemented")
    }
    // swiftlint:enable unavailable_function

    func singleValueContainer() -> SingleValueEncodingContainer {
        self
    }
}

extension InnerStatementEncoder: SingleValueEncodingContainer {

    mutating func encodeNil() throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: nil, for: key.stringValue)
    }

    mutating func encode(_ value: Bool) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: String) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: Double) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: Float) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: Int) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: Int8) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: Int16) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: Int32) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: Int64) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: UInt) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: UInt8) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: UInt16) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

        statement.bind(value: value, for: key.stringValue)
    }

    mutating func encode(_ value: UInt32) throws {
        guard let key = codingPath.last else {
            throw RestructureError.error("Empty current keys")
        }

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

struct InnerStatementEncodingContainer<K : CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K

    // MARK: - Properties

    let codingPath: [CodingKey]

    private var encoder: InnerStatementEncoder
    private let statement: Statement

    // MARK: - Initialization

    init(referencing encoder: InnerStatementEncoder, codingPath: [CodingKey], wrapping statement: Statement) {
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

    // swiftlint:disable:next discouraged_optional_boolean
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

    mutating func encode(_ value: UInt64, forKey _: K) throws {
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

            try value.encode(to: self.encoder)
        }
    }

    mutating func encodeIfPresent<T>(_ value: T?, forKey key: K) throws where T : Encodable {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }

    // swiftlint:disable unavailable_function
    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey _: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Not Implemented")
    }

    mutating func nestedUnkeyedContainer(forKey _: K) -> UnkeyedEncodingContainer {
        fatalError("Not Implemented")
    }

    mutating func superEncoder() -> Encoder {
        fatalError("Not Implemented")
    }

    mutating func superEncoder(forKey _: K) -> Encoder {
        fatalError("Not Implemented")
    }
    // swiftlint:enable unavailable_function
}
