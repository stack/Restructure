//
//  Row.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/4/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import SQLite3

/// A row result from a `Statement`.
public class Row {
    
    // MARK: - Properties
    
    private let statement: Statement
    
    /// The names of the columns present in the row
    public var columns: [String] {
        return Array(statement.columns.keys)
    }
    
    required internal init(statement: Statement) {
        self.statement = statement
    }
    
    // MARK: - Signed Integer Values
    
    private subscript(index: Int32) -> Int {
        let value = sqlite3_column_int64(statement.statement, index)
        return Int(value)
    }
    
    /**
        Returns the `Int` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `Int` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> Int {
        return self[Int32(index)]
    }
    
    /**
        Returns the `Int` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `Int` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> Int {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    private subscript(index: Int32) -> Int8 {
        let value = sqlite3_column_int(statement.statement, index)
        return Int8(value)
    }
    
    /**
        Returns the `Int8` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `Int8` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> Int8 {
        return self[Int32(index)]
    }
    
    /**
        Returns the `Int8` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `Int8` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> Int8 {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    private subscript(index: Int32) -> Int16 {
        let value = sqlite3_column_int(statement.statement, index)
        return Int16(value)
    }
    
    
    /**
        Returns the `Int16` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `Int16` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> Int16 {
        return self[Int32(index)]
    }
    
    /**
        Returns the `Int16` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `Int16` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> Int16 {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    private subscript(index: Int32) -> Int32 {
        let value = sqlite3_column_int(statement.statement, index)
        return value
    }
    
    /**
        Returns the `Int32` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `Int32` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> Int32 {
        return self[Int32(index)]
    }
    
    /**
        Returns the `Int32` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `Int32` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> Int32 {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    private subscript(index: Int32) -> Int64 {
        let value = sqlite3_column_int64(statement.statement, index)
        return value
    }
    
    /**
        Returns the `Int64` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `Int64` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> Int64 {
        return self[Int32(index)]
    }
    
    /**
        Returns the `Int64` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `Int64` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> Int64 {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    // MARK: - Unsigned Integer Values
    
    private subscript(index: Int32) -> UInt {
        let value = sqlite3_column_int64(statement.statement, index)
        return UInt(bitPattern: Int(value))
    }
    
    /**
        Returns the `Int64` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `Int64` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> UInt {
        return self[Int32(index)]
    }
    
    /**
        Returns the `UInt` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `UInt` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> UInt {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    private subscript(index: Int32) -> UInt8 {
        let value = sqlite3_column_int(statement.statement, index)
        return UInt8(bitPattern: Int8(truncatingIfNeeded: value))
    }
    
    /**
        Returns the `UInt8` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `UInt8` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> UInt8 {
        return self[Int32(index)]
    }
    
    /**
        Returns the `UInt8` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `UInt8` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> UInt8 {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    private subscript(index: Int32) -> UInt16 {
        let value = sqlite3_column_int(statement.statement, index)
        print("\(value)")
        return UInt16(bitPattern: Int16(truncatingIfNeeded: value))
    }
    
    /**
        Returns the `UInt16` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `UInt16` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> UInt16 {
        return self[Int32(index)]
    }
    
    /**
        Returns the `UInt16` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `UInt16` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> UInt16 {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    private subscript(index: Int32) -> UInt32 {
        let value = sqlite3_column_int(statement.statement, index)
        return UInt32(bitPattern: value)
    }
    
    /**
        Returns the `UInt32` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `UInt32` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> UInt32 {
        return self[Int32(index)]
    }
    
    /**
        Returns the `UInt32` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `UInt32` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> UInt32 {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    // MARK: - Real Values
    
    private subscript(index: Int32) -> Float {
        let value = sqlite3_column_double(statement.statement, index)
        return Float(value)
    }
    
    /**
        Returns the `Float` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `Float` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> Float {
        return self[Int32(index)]
    }
    
    /**
        Returns the `Float` value for the given index value.
     
     - Parameter key: The key for the given value.
     
     - Returns: The `Float` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> Float {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    private subscript(index: Int32) -> Double {
        let value = sqlite3_column_double(statement.statement, index)
        return value
    }
    
    /**
        Returns the `Double` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `Double` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> Double {
        return self[Int32(index)]
    }
    
    /**
        Returns the `Double` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `Double` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> Double {
        guard let index = statement.columns[key] else {
            return 0
        }
        
        return self[index]
    }
    
    
    // MARK: - Complex Values
    
    private subscript(index: Int32) -> Data? {
        let size = sqlite3_column_bytes(statement.statement, index)
        
        if let data = sqlite3_column_blob(statement.statement, index) {
            return Data(bytes: UnsafeRawPointer(data), count: Int(size))
        } else {
            return nil
        }
    }
    
    /**
        Returns the `Data` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `Data` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> Data? {
        return self[Int32(index)]
    }
    
    /**
        Returns the `Data` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `Data` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> Data? {
        guard let index = statement.columns[key] else {
            return nil
        }
        
        return self[index]
    }
    
    private subscript(index: Int32) -> Date {
        switch statement.dateMode {
        case .integer:
            let time: Int64 = self[index]
            return Date(timeIntervalSince1970: Double(time))
        case .real:
            let time: Double = self[index]
            return Date(julianDays: time)
        case .text:
            guard let time: String = self[index] else {
                fatalError("Could not read time string")
            }
            
            let formatter = ISO8601DateFormatter()
            
            guard let date = formatter.date(from: time) else {
                fatalError("Date was not in ISO 8601 format")
            }
            
            return date
        }
    }
    
    /**
        Returns the `Date` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `Date` value associated with the index, transformed by the underlying SQLite API if necessary.
     
        - SeeAlso: `dateMode` How the date in interpreted from the underlying data.
     */
    public subscript(index: Int) -> Date {
        return self[Int32(index)]
    }
    
    /**
        Returns the `Date` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `Date` value associated with the key, transformed by the underlying SQLite API if necessary.
     
        - SeeAlso: `dateMode` How the date in interpreted from the underlying data.
     */
    public subscript(key: String) -> Date {
        guard let index = statement.columns[key] else {
            return Date(timeIntervalSince1970: 0.0)
        }
        
        return self[index]
    }
    
    private subscript(index: Int32) -> String? {
        guard let data = sqlite3_column_text(statement.statement, index) else {
            return nil
        }
        
        if let (result, _) = String.decodeCString(data, as: UTF8.self) {
            return result
        } else {
            return nil
        }
    }
    
    /**
        Returns the `String` value for the given index value.
     
        - Parameter index: The index for the given value.
     
        - Returns: The `String` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript(index: Int) -> String? {
        return self[Int32(index)]
    }
    
    /**
        Returns the `Data` value for the given index value.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `Data` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript(key: String) -> String? {
        guard let index = statement.columns[key] else {
            return nil
        }
        
        return self[index]
    }
}
