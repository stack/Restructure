//
//  RowDecoder.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2018-11-15.
//  SPDX-License-Identifier: MIT
//

import Foundation

/// A decoder for converting ``Row`` results in to ``Decodable`` types.
public class RowDecoder {

    // MARK: - Initialization

    /// Initializes `self` with the default strategies.
    public init() {
        // NOTE: Empty initializer for public consumption.
    }

    // MARK: - Decoding

    /// Decodes a Row in to a given decodable type.
    ///
    /// - Parameter type: The type to attempt to decode to.
    /// - Parameter from: The Row to decode from.
    ///
    /// - Throws: `Error` if the decoding is not possible.
    public func decode<T : Decodable>(_ type: T.Type, from row: Row) throws -> T {
        let decoder = InnerRowDecoder(referencing: row)

        return try type.init(from: decoder)
    }
}

private class InnerRowDecoder : Decoder {
    let row: Row

    private(set) var codingPath: [CodingKey]
    var currentKeys: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    init(referencing row: Row, at codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
        self.row = row
    }

    func container<Key>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = InnerRowKeyedDecodingContainer<Key>(referencing: self, wrapping: row)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        let rawData: Data = row[key.stringValue]

        let container = InnerRowUnkeyedDecodingContainer(referencing: self, wrapping: rawData)
        return container
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        self
    }
}

extension InnerRowDecoder: SingleValueDecodingContainer {

    func decodeNil() -> Bool {
        guard let key = currentKeys.last else {
            return true
        }

        return row.columnIsNull(key: key.stringValue)
    }

    func decode(_: Bool.Type) throws -> Bool {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: String.Type) throws -> String {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: Double.Type) throws -> Double {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: Float.Type) throws -> Float {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: Int.Type) throws -> Int {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: Int8.Type) throws -> Int8 {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: Int16.Type) throws -> Int16 {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: Int32.Type) throws -> Int32 {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: Int64.Type) throws -> Int64 {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: UInt.Type) throws -> UInt {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: UInt8.Type) throws -> UInt8 {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: UInt16.Type) throws -> UInt16 {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: UInt32.Type) throws -> UInt32 {
        guard let key = currentKeys.last else {
            throw RestructureError.error("Empty current keys")
        }

        return row[key.stringValue]
    }

    func decode(_: UInt64.Type) throws -> UInt64 {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoding UInt64 is not supported"))
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoding \(type) is not supported"))
    }
}

private struct InnerRowKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {
    typealias Key = K

    let decoder: InnerRowDecoder
    let row: Row

    private(set) var codingPath: [CodingKey]

    var allKeys: [K] {
        row.columns.compactMap { Key(stringValue: $0) }
    }

    init(referencing decoder: InnerRowDecoder, wrapping row: Row) {
        self.decoder = decoder
        self.row = row

        self.codingPath = decoder.codingPath
    }

    func contains(_ key: K) -> Bool {
        row.columns.contains(key.stringValue)
    }

    func decodeNil(forKey key: K) throws -> Bool {
        row.columnIsNull(key: key.stringValue)
    }

    func decode(_: Bool.Type, forKey key: K) throws -> Bool {
        row[key.stringValue]
    }

    func decode(_: String.Type, forKey key: K) throws -> String {
        row[key.stringValue]
    }

    func decode(_: Double.Type, forKey key: K) throws -> Double {
        row[key.stringValue]
    }

    func decode(_: Float.Type, forKey key: K) throws -> Float {
        row[key.stringValue]
    }

    func decode(_: Int.Type, forKey key: K) throws -> Int {
        row[key.stringValue]
    }

    func decode(_: Int8.Type, forKey key: K) throws -> Int8 {
        row[key.stringValue]
    }

    func decode(_: Int16.Type, forKey key: K) throws -> Int16 {
        row[key.stringValue]
    }

    func decode(_: Int32.Type, forKey key: K) throws -> Int32 {
        row[key.stringValue]
    }

    func decode(_: Int64.Type, forKey key: K) throws -> Int64 {
        row[key.stringValue]
    }

    func decode(_: UInt.Type, forKey key: K) throws -> UInt {
        row[key.stringValue]
    }

    func decode(_: UInt8.Type, forKey key: K) throws -> UInt8 {
        row[key.stringValue]
    }

    func decode(_: UInt16.Type, forKey key: K) throws -> UInt16 {
        row[key.stringValue]
    }

    func decode(_: UInt32.Type, forKey key: K) throws -> UInt32 {
        row[key.stringValue]
    }

    func decode(_: UInt64.Type, forKey _: K) throws -> UInt64 {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoding UInt64 is not supported"))
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        // swiftlint:disable:next legacy_objc_type
        if type == Data.self || type == NSData.self {
            let data: Data = row[key.stringValue]

            guard let decodableValue = data as? T else {
                throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Decoding \(key.stringValue) is not convertable to a Decodable"))
            }

            return decodableValue
        // swiftlint:disable:next legacy_objc_type
        } else if type == Date.self || type == NSDate.self {
            let date: Date = row[key.stringValue]

            guard let decodableValue = date as? T else {
                throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Decoding \(key.stringValue) is not convertable to a Decodable"))
            }

            return decodableValue
        } else {
            decoder.currentKeys.append(key)
            defer { decoder.currentKeys.removeLast() }

            return try type.init(from: decoder)
        }
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey _: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw RestructureError.error("nestedContainer Not Implemented")
    }

    func nestedUnkeyedContainer(forKey _: K) throws -> UnkeyedDecodingContainer {
        throw RestructureError.error("nestedUnkeyedContainer Not Implemented")
    }

    func superDecoder() throws -> Decoder {
        throw RestructureError.error("superDecoder Not Implemented")
    }

    func superDecoder(forKey _: K) throws -> Decoder {
        throw RestructureError.error("superDecoder Not Implemented")
    }
}

private struct InnerRowUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    private let decoder: InnerRowDecoder
    private let array: [Any]

    var codingPath: [CodingKey]

    var count: Int? {
        array.count
    }

    var isAtEnd: Bool {
        guard let count else { return false }

        return currentIndex >= count
    }

    var currentIndex: Int

    init(referencing decoder: InnerRowDecoder, wrapping rawData: Data) {
        self.decoder = decoder
        self.codingPath = decoder.codingPath
        self.currentIndex = 0

        let array: Any

        switch decoder.row.arrayStrategy {
        case .bplist:
            do {
                array = try PropertyListSerialization.propertyList(from: rawData, options: .mutableContainersAndLeaves, format: nil)
            } catch {
                fatalError("Failed to deserialize binary plist: \(error)")
            }
        case .json:
            do {
                array = try JSONSerialization.jsonObject(with: rawData, options: [])
            } catch {
                fatalError("Failed to deserialize JSON: \(error)")
            }
        }

        guard let finalArray = array as? [Any] else {
            fatalError("Failed to convert final array")
        }

        self.array = finalArray
    }

    mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        if array[currentIndex] is NSNull {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? Bool else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: String.Type) throws -> String {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? String else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? Double else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? Float else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? Int else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? Int8 else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? Int16 else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? Int32 else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? Int64 else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? UInt else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? UInt8 else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? UInt16 else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? UInt32 else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? UInt64 else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Unkeyed container is at end"))
        }

        guard let value = array[currentIndex] as? T else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_RowKey(intValue: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        currentIndex += 1

        return value
    }

    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw RestructureError.error("nestedContainer Not Implemented")
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw RestructureError.error("nestedUnkeyedContainer Not Implemented")
    }

    mutating func superDecoder() throws -> Decoder {
        throw RestructureError.error("superDecoder Not Implemented")
    }
}

private struct _RowKey: CodingKey {

    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(stringValue: String, intValue: Int) {
        self.stringValue = stringValue
        self.intValue = intValue
    }
}
