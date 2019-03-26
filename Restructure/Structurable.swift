//
//  Bindable.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import SQLite3

/// Defines the types that can be converted to and from a SQLite value.
public protocol Structurable {
    static func from(_ statement: Statement, at index: Int) -> Self
    func bind(to statement: Statement, at index: Int)
}

extension Bool: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Bool {
        let value = sqlite3_column_int(statement.statement, Int32(index))
        return (value != 0)
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_int(statement.statement, Int32(index), self ? 1 : 0)
    }
}

extension Int: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Int {
        let value = sqlite3_column_int64(statement.statement, Int32(index))
        return Int(value)
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_int64(statement.statement, Int32(index), Int64(self))
    }
}

extension Int8: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Int8 {
        let value = sqlite3_column_int(statement.statement, Int32(index))
        return Int8(value)
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_int(statement.statement, Int32(index), Int32(self))
    }
}

extension Int16: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Int16 {
        let value = sqlite3_column_int(statement.statement, Int32(index))
        return Int16(value)
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_int(statement.statement, Int32(index), Int32(self))
    }
}

extension Int32: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Int32 {
        let value = sqlite3_column_int(statement.statement, Int32(index))
        return value
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_int(statement.statement, Int32(index), self)
    }
}

extension Int64: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Int64 {
        let value = sqlite3_column_int64(statement.statement, Int32(index))
        return value
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_int64(statement.statement, Int32(index), self)
    }
}

extension UInt: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> UInt {
        let value = sqlite3_column_int64(statement.statement, Int32(index))
        return UInt(bitPattern: Int(value))
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_int64(statement.statement, Int32(index), Int64(bitPattern: UInt64(self)))
    }
}

extension UInt8: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> UInt8 {
        let value = sqlite3_column_int(statement.statement, Int32(index))
        return UInt8(bitPattern: Int8(truncatingIfNeeded: value))
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_int(statement.statement, Int32(index), Int32(bitPattern: UInt32(self)))
    }
}

extension UInt16: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> UInt16 {
        let value = sqlite3_column_int(statement.statement, Int32(index))
        return UInt16(bitPattern: Int16(truncatingIfNeeded: value))
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_int(statement.statement, Int32(index), Int32(bitPattern: UInt32(self)))
    }
}

extension UInt32: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> UInt32 {
        let value = sqlite3_column_int(statement.statement, Int32(index))
        return UInt32(bitPattern: value)
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_int64(statement.statement, Int32(index), Int64(bitPattern: UInt64(self)))
    }
}

extension Float: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Float {
        let value = sqlite3_column_double(statement.statement, Int32(index))
        return Float(value)
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_double(statement.statement, Int32(index), Double(self))
    }
}

extension Double: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Double {
        let value = sqlite3_column_double(statement.statement, Int32(index))
        return value
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_double(statement.statement, Int32(index), self)
    }
}

extension Data: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Data {
        let size = sqlite3_column_bytes(statement.statement, Int32(index))
        
        if let data = sqlite3_column_blob(statement.statement, Int32(index)) {
            return Data(bytes: UnsafeRawPointer(data), count: Int(size))
        } else {
            fatalError("Fetched non-null data was null")
        }
    }
    
    public func bind(to statement: Statement, at index: Int) {
        withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Void in
            sqlite3_bind_blob(statement.statement, Int32(index), bytes.baseAddress, Int32(self.count), SQLITE_TRANSIENT)
        }
    }
}

extension Date: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Date {
        switch statement.dateStrategy {
        case .integer:
            let time = Int64.from(statement, at: index)
            return Date(timeIntervalSince1970: Double(time))
        case .real:
            let time = Double.from(statement, at: index)
            return Date(julianDays: time)
        case .text:
            let time = String.from(statement, at: index)
            let formatter = ISO8601DateFormatter()
            
            guard let date = formatter.date(from: time) else {
                fatalError("Fetched time string was not ISO 8601 formatted")
            }
            
            return date
        }
    }
    
    public func bind(to statement: Statement, at index: Int) {
        switch statement.dateStrategy {
        case .integer:
            let time = self.timeIntervalSince1970
            sqlite3_bind_int64(statement.statement, Int32(index), Int64(time))
        case .real:
            let time = self.julianDays
            sqlite3_bind_double(statement.statement, Int32(index), time)
        case .text:
            let formatter = ISO8601DateFormatter()
            let time = formatter.string(from: self)
            sqlite3_bind_text(statement.statement, Int32(index), time, Int32(time.utf8.count), SQLITE_TRANSIENT)
        }
    }
}

extension String: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> String {
        guard let data = sqlite3_column_text(statement.statement, Int32(index)) else {
            fatalError("Fetched non-null string was null")
        }
        
        if let (result, _) = String.decodeCString(data, as: UTF8.self) {
            return result
        } else {
            fatalError("Fetched non-null string was not UTF-8")
        }
    }
    
    public func bind(to statement: Statement, at index: Int) {
        sqlite3_bind_text(statement.statement, Int32(index), self, Int32(self.utf8.count), SQLITE_TRANSIENT)
    }
}

extension Array: Structurable where Element: Structurable {
    public static func from(_ statement: Statement, at index: Int) -> Array<Element> {
        let size = sqlite3_column_bytes(statement.statement, Int32(index))
        
        guard let rawData = sqlite3_column_blob(statement.statement, Int32(index)) else {
            fatalError("Could not get array data blob")
        }
        
        let data = Data(bytes: rawData, count: Int(size))
        let array: Any
        
        switch statement.arrayStrategy {
        case .bplist:
            do {
                array = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil)
            } catch {
                fatalError("Failed to deserialize binary plist: \(error)")
            }
        case .json:
            do {
                array = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                fatalError("Failed to deserialize JSON: \(error)")
            }
        }
        
        guard let finalArray = array as? Array<Element> else {
            fatalError("Failed to convert deserialized data to array of \(Element.self)")
        }
        
        return finalArray
    }
    
    public func bind(to statement: Statement, at index: Int) {
        let data: Data
        
        switch statement.arrayStrategy {
        case .bplist:
            do {
                data = try PropertyListSerialization.data(fromPropertyList: self, format: .binary, options: 0)
            } catch {
                fatalError("Failed to serialize property list: \(error)")
            }
        case .json:
            do {
                data = try JSONSerialization.data(withJSONObject: self, options: [])
            } catch {
                fatalError("Failed to serialize JSON: \(error)")
            }
        }
        
        data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Void in
            sqlite3_bind_blob(statement.statement, Int32(index), bytes.baseAddress, Int32(data.count), SQLITE_TRANSIENT)
        }
    }
}
