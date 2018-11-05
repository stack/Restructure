//
//  Statement.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import SQLite3

private let ValidBindPrefixes = [":", "$", "@"]

public class Statement {
    
    // MARK: - Properties
    
    internal let restructure: Restructure
    internal let statement: SQLiteStatement
    
    internal var bindables: [String:Int32] = [:]
    internal var columns: [String:Int32] = [:]
    
    public var dateMode: DateMode = .integer
    
    public var bindableNames: [String] {
        return Array(bindables.keys)
    }
    
    public var columnNames: [String] {
        return Array(columns.keys)
    }
    
    
    // MARK: - Initialization
    
    required internal init(restructure: Restructure, query: String) throws {
        self.restructure = restructure
        
        // Build the underlying statement
        var statement: SQLiteStatement? = nil
        let result = sqlite3_prepare_v2(restructure.db, query, -1, &statement, nil)
        
        if result != SQLITE_OK {
            throw RestructureError.from(result: result)
        }
        
        guard let actualStatement = statement else {
            fatalError("Prepared statement successfully, but did not get a statement object")
        }
        
        // Store it!
        self.statement = actualStatement
        
        // Reload metadata about the statement
        reloadBindables()
        reloadColumns()
    }
    
    private func reloadBindables() {
        // Clear the current list
        bindables.removeAll()
        
        // Get the nunber of bindables, because they're indexed starting at 1
        let count = sqlite3_bind_parameter_count(statement)
        
        guard count > 0 else {
            return
        }
        
        // Iterate through the bindables, capturing the name and index
        for idx in 1 ... count {
            // Ensure we have a name
            guard let bindName = sqlite3_bind_parameter_name(statement, idx) else {
                continue
            }
            
            // Ensure we have readable name
            guard let name = String(validatingUTF8: bindName) else {
                continue
            }
            
            // Ensure there actual is a name
            guard !name.isEmpty else {
                continue
            }
            
            // Ensure the name had a binding prefix
            let nameIndex = name.index(after: name.startIndex)
            let token = String(name.prefix(upTo: nameIndex))
            
            if !ValidBindPrefixes.contains(token) {
                continue
            }
            
            // Valid, so store it without the prefix
            let finalName = String(name.suffix(from: nameIndex))
            bindables[finalName] = idx
        }
    }
    
    private func reloadColumns() {
        // Clear the current list
        columns.removeAll()
        
        // Iterate through the columns
        let count = sqlite3_column_count(statement)
        for idx in 0 ..< count {
            let columnName = sqlite3_column_name(statement, idx)
            
            guard let column = columnName else {
                continue;
            }
            
            guard let name = String(validatingUTF8: column) else {
                continue;
            }
            
            columns[name] = idx
        }
    }
    
    deinit {
        sqlite3_finalize(statement)
    }
    
    public func reset() {
        let result = sqlite3_reset(statement)
        
        if result != SQLITE_OK {
            let error = RestructureError.from(result: result)
            fatalError("Failed to reset the statement: \(error)")
        }
    }
    
    // MARK: - Binding
    
    /**
        Bind a `Bindable` value to the given index.
 
        - Parameter value: The `Bindable` value to assign to the index.
        - Parameter at: The index to bind to.
        - Remark:
            Bindable indexes start at 1, not 0.
    */
    public func bind(value: Bindable?, at index: Int32) {
        precondition(index > 0)
        
        // If we didn't get a value, bind NULL.
        guard let bindable = value else {
            sqlite3_bind_null(statement, index)
            return
        }
        
        // Bind the appropriate type
        switch bindable {
        case let x as Int:
            sqlite3_bind_int64(statement, index, Int64(x))
        case let x as Int8:
            sqlite3_bind_int(statement, index, Int32(x))
        case let x as Int16:
            sqlite3_bind_int(statement, index, Int32(x))
        case let x as Int32:
            sqlite3_bind_int(statement, index, x)
        case let x as Int64:
            sqlite3_bind_int64(statement, index, x)
        case let x as UInt:
            sqlite3_bind_int64(statement, index, Int64(bitPattern: UInt64(x)))
        case let x as UInt8:
            sqlite3_bind_int(statement, index, Int32(bitPattern: UInt32(x)))
        case let x as UInt16:
            sqlite3_bind_int(statement, index, Int32(bitPattern: UInt32(x)))
        case let x as UInt32:
            sqlite3_bind_int64(statement, index, Int64(bitPattern: UInt64(x)))
        case let x as Float:
            sqlite3_bind_double(statement, index, Double(x))
        case let x as Double:
            sqlite3_bind_double(statement, index, x)
        case let x as Data:
            x.withUnsafeBytes { data -> Void in
                sqlite3_bind_blob(statement, index, data, Int32(x.count), SQLITE_TRANSIENT)
            }
        case let x as Date:
            switch dateMode {
            case .integer:
                let time = x.timeIntervalSince1970
                sqlite3_bind_int64(statement, index, Int64(time))
            case .real:
                let time = x.julianDays
                sqlite3_bind_double(statement, index, time)
            case .text:
                let formatter = ISO8601DateFormatter()
                let time = formatter.string(from: x)
                sqlite3_bind_text(statement, index, time, Int32(time.utf8.count), SQLITE_TRANSIENT)
            }
        case let x as String:
            sqlite3_bind_text(statement, index, x, Int32(x.utf8.count), SQLITE_TRANSIENT)
        default:
            fatalError("Unhandled bindable type: \(bindable.self)")
        }
    }
    
    /**
     Bind a `Bindable` value to the given index.
     
     - Parameter value: The `Bindable` value to assign to the index.
     - Parameter for: The name of the bindable.
     - Remark:
        Bindable indexes start at 1, not 0.
        Bindable names start with ':', '@', or '$' when the statement is prepared. They are referenced here without the prefix.
     */
    public func bind(value: Bindable?, for key: String) {
        // Ensure we can map a parameter to an index
        guard let index = bindables[key] else {
            return
        }
        
        // Pass the value with the proper index
        bind(value: value, at: index)
    }
    
    
    // MARK: - Execution
    
    /**
        Evaluate the statement, returning the result of the evaluation.
 
        - Returns: The result of the evaluation. Different statements returns different sets of results.
        - Remark:
            For statements that return rows, you will get a series of `row`s followed by `done`.
            For all other statements, you will get `done` on success.
     */
    public func step() -> StepResult {
        let result = sqlite3_step(statement)
        
        switch result {
        case SQLITE_BUSY:
            return .busy
        case SQLITE_DONE:
            return .done
        case SQLITE_ERROR:
            return .error(RestructureError.from(result: result))
        case SQLITE_MISUSE:
            return .misuse
        case SQLITE_ROW:
            return .row(Row(statement: self))
        default:
            fatalError("Failed to handle step result \(result)")
        }
    }
    
}
