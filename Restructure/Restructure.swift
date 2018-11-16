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
    
    /// The default array strategy used for all statements generated from this instance
    public var arrayStrategy: ArrayStrategy = .bplist
    
    /// The default date strategy used for all statements generated from this instance
    public var dateStrategy: DateStrategy = .integer
    
    internal let db: SQLiteDatabase
    private var isOpen: Bool
    
    /// Get the last inserted ID in to the database
    public var lastInsertedId: Int64 {
        return sqlite3_last_insert_rowid(db)
    }
    
    /// A number stored along with the database, typically used for schema versioning
    public internal(set) var userVersion: Int {
        get {
            do {
                let statement = try prepare(query: "PRAGMA user_version")
                let result = statement.step()
                
                switch result {
                case let .row(row):
                    return row[0]
                default:
                    fatalError("Failed to fetch user_version pragma from a result: \(result)")
                }
            } catch {
                fatalError("Failed to fetching user_version pragma: \(error)")
            }
        }
        
        set {
            let result = sqlite3_exec(db, "PRAGMA user_version = \(newValue)", nil, nil, nil)
            
            if result != SQLITE_OK {
                let error = RestructureError.from(result: result)
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
     
        - Parameter path: The full path to the Structure object to open or create.
     
        - Throws: `StructureError.InternalError` if opening the database fails.
     */
    required public init(path: String) throws {
        // Build the database object
        var db: SQLiteDatabase? = nil
        let result = sqlite3_open_v2(path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
        
        // Check if it was successful
        if result != SQLITE_OK {
            throw RestructureError.from(result: result)
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
    
    // MARK: - Querying
    
    /**
        Simply executes a statement with a success / failure result.
 
        - Parameter query: The SQL statement to execute
 
        - Throws: `StructureError.InternalError` if the execution failed.
    */
    
    public func execute(query: String) throws {
        var errorMessage: UnsafeMutablePointer<Int8>? = nil
        let result = sqlite3_exec(db, query, nil, nil, &errorMessage)
        
        var potentialError: RestructureError? = nil
        
        if result != SQLITE_OK, let rawMessage = errorMessage {
            if let message = String(validatingUTF8: rawMessage) {
                potentialError = RestructureError.internalError(result, message)
            }
            
            sqlite3_free(errorMessage)
        }
        
        if let error = potentialError {
            throw error
        }
    }
    
    /**
        Prepare a new `Statement` for the database
     
        - Parameter query: The SQL statement to prepare
     
        - Throws: `StructureError.InternalError` if the statement cannot be parsed.
     
        - Returns: An unexecuted, unbound statement.
     */
    public func prepare(query: String) throws -> Statement {
        let statement = try Statement(restructure: self, query: query)
        statement.arrayStrategy = arrayStrategy
        statement.dateStrategy = dateStrategy
        
        return statement
    }
}
