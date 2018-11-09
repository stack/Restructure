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
    
    // MARK: - Data Subscripts
    
    private subscript<T: Structurable>(index: Int32) -> T {
        // Non-null return type, so ensure the value isn't actually null
        if sqlite3_column_type(statement.statement, index) == SQLITE_NULL {
            fatalError("Attempted to fetch a non-null statement column that contained null")
        }
        
        // Convert to the proper type
        switch T.self {
        case is Int.Type:
            let value = sqlite3_column_int64(statement.statement, index)
            return Int(value) as! T
        case is Int8.Type:
            let value = sqlite3_column_int(statement.statement, index)
            return Int8(value) as! T
        case is Int16.Type:
            let value = sqlite3_column_int(statement.statement, index)
            return Int16(value) as! T
        case is Int32.Type:
            let value = sqlite3_column_int(statement.statement, index)
            return value as! T
        case is Int64.Type:
            let value = sqlite3_column_int64(statement.statement, index)
            return value as! T
        case is UInt.Type:
            let value = sqlite3_column_int64(statement.statement, index)
            return UInt(bitPattern: Int(value)) as! T
        case is UInt8.Type:
            let value = sqlite3_column_int(statement.statement, index)
            return UInt8(bitPattern: Int8(truncatingIfNeeded: value)) as! T
        case is UInt16.Type:
            let value = sqlite3_column_int(statement.statement, index)
            return UInt16(bitPattern: Int16(truncatingIfNeeded: value)) as! T
        case is UInt32.Type:
            let value = sqlite3_column_int(statement.statement, index)
            return UInt32(bitPattern: value) as! T
        case is Float.Type:
            let value = sqlite3_column_double(statement.statement, index)
            return Float(value) as! T
        case is Double.Type:
            let value = sqlite3_column_double(statement.statement, index)
            return value as! T
        case is Data.Type:
            let size = sqlite3_column_bytes(statement.statement, index)
            
            if let data = sqlite3_column_blob(statement.statement, index) {
                return Data(bytes: UnsafeRawPointer(data), count: Int(size)) as! T
            } else {
                fatalError("Fetched non-null data was null")
            }
        case is Date.Type:
            switch statement.dateMode {
            case .integer:
                let time: Int64 = self[index]
                return Date(timeIntervalSince1970: Double(time)) as! T
            case .real:
                let time: Double = self[index]
                return Date(julianDays: time) as! T
            case .text:
                let time: String = self[index]
                let formatter = ISO8601DateFormatter()
            
                guard let date = formatter.date(from: time) else {
                    fatalError("Fetched time string was not ISO 8601 formatted")
                }
            
                return date as! T
            }
        case is String.Type:
            guard let data = sqlite3_column_text(statement.statement, index) else {
                fatalError("Fetched non-null string was null")
            }
            
            if let (result, _) = String.decodeCString(data, as: UTF8.self) {
                return result as! T
            } else {
                fatalError("Fetched non-null string was not UTF-8")
            }
        default:
            fatalError("Unhandled Structurable type unhandled: \(T.self)")
        }
    }
    
    private subscript<T: Structurable>(index: Int32) -> T? {
        // Non-null return type, so ensure the value isn't actually null
        if sqlite3_column_type(statement.statement, index) == SQLITE_NULL {
            return nil
        }
        
        let result: T = self[index]
        return result
    }
    
    /**
        Returns the non-null `Structurable` value for the given index value.
     
        - Parameter index: The index of the given value.
     
        - Returns: The `Structurable` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript<T: Structurable>(index: Int) -> T {
        return self[Int32(index)]
    }
    
    /**
        Returns the non-null `Structurable` value for the given key.
     
        - Parameter key: The key for the given value.
     
        - Returns: The `Structurable` value associated with the key, transformed by the underlying SQLite API if necessary.
     */
    public subscript<T: Structurable>(key: String) -> T {
        guard let index = statement.columns[key] else {
            fatalError("Attempted to access the subscript of an unknown key")
        }
        
        return self[index]
    }
    
    /**
     Returns the nullable `Structurable` value for the given index value.
     
     - Parameter index: The index of the given value.
     
     - Returns: The `Structurable` value associated with the index, transformed by the underlying SQLite API if necessary, or `nil`.
     */
    public subscript<T: Structurable>(index: Int) -> T? {
        return self[Int32(index)]
    }
    
    /**
     Returns the nullable `Structurable` value for the given key.
     
     - Parameter key: The key for the given value.
     
     - Returns: The `Structurable` value associated with the key, transformed by the underlying SQLite API if necessary, or `nil`.
     */
    public subscript<T: Structurable>(key: String) -> T? {
        guard let index = statement.columns[key] else {
            fatalError("Attempted to access the subscript of an unknown key")
        }
        
        return self[index]
    }
}
