//
//  Restructure.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import SQLite3

/// Type aliases for common SQLite pointers
internal typealias SQLiteDatabase = OpaquePointer
internal typealias SQLiteStatement = OpaquePointer

/// Proper import for the SQLite string memory functions
internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

/// The primary class for interfacing with SQLite databases
public class Restructure {
    
    // MARK: - Properties
    
    internal let db: SQLiteDatabase
    private var isOpen: Bool
    
    /// Get the last inserted ID in to the database
    public var lastInsertedId: Int64 {
        return sqlite3_last_insert_rowid(db)
    }
    
    /// A number stored along with the database, typically used for schema versioning
    public internal(set) var userVersion: Int {
        get {
            var statement: SQLiteStatement? = nil
            var result = sqlite3_prepare_v2(db, "PRAGMA user_version", -1, &statement, nil)
            
            if result != SQLITE_OK {
                let error = StructureError.from(result: result)
                fatalError("Failed to prepare the get user_version statement: \(error)")
            }
            
            guard let actualStatement = statement else {
                fatalError("Prepared a get user_version statement, but no statement was given")
            }
            
            defer {
                sqlite3_finalize(actualStatement)
            }
            
            result = sqlite3_step(actualStatement)
            
            if result != SQLITE_ROW {
                let error = StructureError.from(result: result)
                fatalError("Failed to step the user_version statement: \(error)")
            }
            
            let version = sqlite3_column_int(statement, 0)
            return Int(version)
        }
        
        set {
            let result = sqlite3_exec(db, "PRAGMA user_version = \(newValue)", nil, nil, nil)
            
            if result != SQLITE_OK {
                let error = StructureError.from(result: result)
                fatalError("Failed to set the user_version: \(error)")
            }
        }
    }
    
    
    // MARK: - Initialization
    
    /**
     Initializes a new Structure object with all data stored in memory. No data will be persisted.
     
     - Throws: `StructureError.InternalError` if opening the database fails.
     */
    convenience public init() throws {
        try self.init(path: ":memory:")
    }
    
    /**
     Initializes a new Structure object at the given path. If the file already exists, it will be opened, otherwise it will be created.
     
     - Parameters:
     - path: The full path to the Structure object to open or create.
     
     - Throws: `StructureError.InternalError` if opening the database fails.
     */
    required public init(path: String) throws {
        // Build the database object
        var db: SQLiteDatabase? = nil
        let result = sqlite3_open_v2(path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
        
        // Check if it was successful
        if result != SQLITE_OK {
            throw StructureError.from(result: result)
        }
        
        // Sanily check that the database pointer got made
        guard let actualDb = db else {
            fatalError("sqlite3_open_v2 was successful, but no database pointer was made")
        }
        
        self.db = actualDb
        isOpen = true
        
        // Register all of the custom functions
        registerFunctions()
    }
    
    /// Close a Structure object. Once closed, a Structure object should not be used again. The behaviour is undefined.
    public func close() {
        if (isOpen) {
            sqlite3_close_v2(db)
            isOpen = false
        }
    }
    
    deinit {
        close()
    }
    
    private func registerFunctions() {
        sqlite3_create_function(db, "UPPER", 1, SQLITE_UTF8, nil, { (context, numberOfArguments, arguments) in
            guard let args = arguments else {
                sqlite3_result_error(context, "UPPER could not unwrap arguments", -1)
                return
            }
            
            let firstArg = args.advanced(by: 0)
            guard let firstData = firstArg.pointee else {
                sqlite3_result_error(context, "UPPER could not get first argument data", -1)
                return
            }
            
            guard let value = sqlite3_value_text(firstData) else {
                sqlite3_result_error(context, "UPPER could not get text from first argument", -1)
                return
            }
            
            let stringValue = String(cString: value).uppercased()
            
            stringValue.withCString {
                sqlite3_result_text(context, $0, Int32(stringValue.lengthOfBytes(using: .utf8)), SQLITE_STATIC)
            }
        }, nil, nil)
    }
}
