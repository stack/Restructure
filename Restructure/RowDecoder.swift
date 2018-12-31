//
//  RowDecoder.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/15/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

public class RowDecoder {
    
    // MARK: - Initialization
    
    /// Initializes `self` with the default strategies.
    public init() { }
    
    // MARK: - Decoding
    
    /**
        Decodes a Row in to a given decodable type.
     
        - Parameter type: The type to attempt to decode to.
     
        - Parameter from: The Row to decode from.
     
        - Throws: `Error` if the decoding is not possible.
     */
    public func decode<T : Decodable>(_ type: T.Type, from row: Row) throws -> T {
        let decoder = _RowDecoder(referencing: row)
        
        return try type.init(from: decoder)
    }
}

fileprivate class _RowDecoder : Decoder {
    fileprivate let row: Row
    
    fileprivate(set) var codingPath: [CodingKey]
    fileprivate var currentKeys: [CodingKey] = []
    
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    fileprivate init(referencing row: Row, at codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
        self.row = row
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = _RowKeyedDecodingContainer<Key>(referencing: self, wrapping: row)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        precondition(!currentKeys.isEmpty, "Empty current keys")
        
        let rawData: Data = row[currentKeys.last!.stringValue]
        
        let container = _RowUnkeyedDecodingContainer(referencing: self, wrapping: rawData)
        return container
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError("Not Implemented")
    }
}

fileprivate struct _RowKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {
    typealias Key = K
    
    let decoder: _RowDecoder
    let row: Row
    
    fileprivate(set) var codingPath: [CodingKey]
    
    var allKeys: [K] {
        return row.columns.compactMap { Key(stringValue: $0) }
    }
    
    fileprivate init(referencing decoder: _RowDecoder, wrapping row: Row) {
        self.decoder = decoder
        self.row = row
        
        self.codingPath = decoder.codingPath
    }
    
    func contains(_ key: K) -> Bool {
        return row.columns.contains(key.stringValue)
    }
    
    func decodeNil(forKey key: K) throws -> Bool {
        return row.columnIsNull(key: key.stringValue)
    }
    
    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        return row[key.stringValue]
    }
    
    func decode(_ type: String.Type, forKey key: K) throws -> String {
        return row[key.stringValue]
    }
    
    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        return row[key.stringValue]
    }
    
    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        return row[key.stringValue]
    }
    
    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        return row[key.stringValue]
    }
    
    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        return row[key.stringValue]
    }
    
    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        return row[key.stringValue]
    }
    
    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        return row[key.stringValue]
    }
    
    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        return row[key.stringValue]
    }
    
    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        return row[key.stringValue]
    }
    
    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        return row[key.stringValue]
    }
    
    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        return row[key.stringValue]
    }
    
    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        return row[key.stringValue]
    }
    
    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoding UInt64 is not supported"))
    }
    
    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        if type == Data.self || type == NSData.self {
            let data: Data = row[key.stringValue]

            guard let decodableValue = data as? T else {
                throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Decoding \(key.stringValue) is not convertable to a Decodable"))
            }
            
            return decodableValue
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
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Not Implemented")
    }
    
    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        fatalError("Not Implemented")
    }
    
    func superDecoder() throws -> Decoder {
        fatalError("Not Implemented")
    }
    
    func superDecoder(forKey key: K) throws -> Decoder {
        fatalError("Not Implemented")
    }
    
}

fileprivate struct _RowUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    private let decoder: _RowDecoder
    private let array: [Any]
    
    var codingPath: [CodingKey]
    
    var count: Int? {
        return array.count
    }
    
    var isAtEnd: Bool {
        return self.currentIndex >= self.count!
    }
    
    var currentIndex: Int
    
    fileprivate init(referencing decoder: _RowDecoder, wrapping rawData: Data) {
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
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Not Implemented")
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("Not Implemented")
    }
    
    mutating func superDecoder() throws -> Decoder {
        fatalError("Not Implemented")
    }
}

fileprivate struct _RowKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?
    
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    public init(stringValue: String, intValue: Int) {
        self.stringValue = stringValue
        self.intValue = intValue
    }
}
