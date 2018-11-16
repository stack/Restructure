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
    
    /**
        Returns the non-null `Structurable` value for the given index value.
     
        - Parameter index: The index of the given value.
     
        - Returns: The `Structurable` value associated with the index, transformed by the underlying SQLite API if necessary.
     */
    public subscript<T: Structurable>(index: Int) -> T {
        // Non-null return type, so ensure the value isn't actually null
        if sqlite3_column_type(statement.statement, Int32(index)) == SQLITE_NULL {
            fatalError("Attempted to fetch a non-null statement column that contained null")
        }
        
        // Return the actual value
        return T.from(statement, at: index)
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
        
        return self[Int(index)]
    }
    
    /**
     Returns the nullable `Structurable` value for the given index value.
     
     - Parameter index: The index of the given value.
     
     - Returns: The `Structurable` value associated with the index, transformed by the underlying SQLite API if necessary, or `nil`.
     */
    public subscript<T: Structurable>(index: Int) -> T? {
        // Non-null return type, so ensure the value isn't actually null
        if sqlite3_column_type(statement.statement, Int32(index)) == SQLITE_NULL {
            return nil
        }
        
        // Return the actual value
        return T.from(statement, at: index)
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
        
        return self[Int(index)]
    }
}
