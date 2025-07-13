//
//  Restructure.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2018-11-03.
//  SPDX-License-Identifier: MIT
//

import Foundation
import SQLite3

/// Type aliases for common SQLite pointers
typealias SQLiteDatabase = OpaquePointer
typealias SQLiteStatement = OpaquePointer

// swiftlint:disable identifier_name

/// Proper import for the SQLite string memory functions
let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

// swiftlint:enable identifier_name

/// The primary class for interfacing with SQLite databases
public class Restructure {

    // MARK: - Properties

    /// The default array strategy used for all statements generated from this instance
    public var arrayStrategy: ArrayStrategy = .bplist

    /// The default date strategy used for all statements generated from this instance
    public var dateStrategy: DateStrategy = .integer

    /// If an instance is temporary, the following occur on `close`:
    /// -   The file used for storing the database will be deleted.
    public var isTemporary: Bool = false

    /// The auto vacuum mode used by the dtabase. The default is `.none`.
    public var autoVacuum: AutoVacuum {
        get { get(pragma: "auto_vacuum") }
        set { set(pragma: "auto_vacuum", value: newValue) }
    }

    /// The journaling mode used by the database. The default is `.memory` for in-memory databases and `.wal` for file-backed databases.
    public var journalMode: JournalMode {
        get { get(pragma: "journal_mode") }
        set { set(pragma: "journal_mode", value: newValue) }
    }

    /// The method used when deleting data.
    public var secureDelete: SecureDelete {
        get { get(pragma: "secure_delete") }
        set { set(pragma: "secure_delete", value: newValue) }
    }

    let db: SQLiteDatabase
    private var isOpen: Bool

    private let path: String?

    private var preparedStatements: Set<SQLiteStatement> = []

    /// Get the last inserted ID in to the database
    public var lastInsertedId: Int64 {
        sqlite3_last_insert_rowid(db)
    }

    /// A number stored along with the database, typically used for schema versioning
    public internal(set) var userVersion: Int {
        get { get(pragma: "user_version") }
        set { set(pragma: "user_version", value: newValue) }
    }

    /// The underlying SQLite version {
    public var sqliteVersion: String {
        do {
            let statement = try prepare(query: "SELECT sqlite_version()")
            let result = statement.step()

            switch result {
            case let .row(row):
                return row[0]
            default:
                fatalError("Failed to fetch sqlite_version from a result: \(result)")
            }
        } catch {
            fatalError("Failed to fetch sqlite_version: \(error)")
        }
    }

    // MARK: - Initialization

    /// Initializes a new Structure object with all data stored in memory. No data will be persisted.
    ///
    /// - Parameter readOnly: Open the database as read-only. Default is false.
    /// 
    /// - Throws: `StructureError.InternalError` if opening the database fails.
    public convenience init(readOnly: Bool = false) throws {
        try self.init(path: ":memory:", readOnly: readOnly)
    }

    /// Initializes a new Structure object at the given path. If the file already exists, it will be opened, otherwise it will be created.
    ///
    /// - Parameter path: The full path to the Structure object to open or create.
    /// - Parameter journalMode: The SQLite journaling mode. Default is WAL.
    /// - Parameter readOnly: Open the database as read-only. Default is false.
    ///
    /// - Throws: `StructureError.InternalError` if opening the database fails.
    public required init(path: String, journalMode: JournalMode = .wal, readOnly: Bool = false) throws {
        // Build the database object
        var db: SQLiteDatabase? = nil

        let result: Int32

        if readOnly {
            result = sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil)
        } else {
            result = sqlite3_open_v2(path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
        }

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

        if path == ":memory:" {
            self.path = nil
        } else {
            self.path = path
        }

        // Set up the database settings
        self.journalMode = journalMode

        // Register all of the custom functions
        registerFunctions()
    }

    /// Close a Structure object. Once closed, a Structure object should not be used again. The behaviour is undefined.
    public func close() {
        // Prevent multiple closes
        guard isOpen else {
            return
        }

        // Finalize all known statements
        for statement in preparedStatements {
            sqlite3_finalize(statement)
        }

        preparedStatements.removeAll()

        // In WAL mode, force a flush
        if journalMode == .wal {
            sqlite3_wal_checkpoint_v2(db, nil, SQLITE_CHECKPOINT_TRUNCATE, nil, nil)
        }

        // Final close
        sqlite3_close_v2(db)
        isOpen = false
    }

    deinit {
        close()
    }

    private func registerFunctions() {
        // swiftlint:disable multiline_arguments
        sqlite3_create_function(db, "UPPER", 1, SQLITE_UTF8, nil, { context, _, arguments in
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

            stringValue.withCString { value in
                sqlite3_result_text(context, value, Int32(stringValue.utf8.count), SQLITE_TRANSIENT)
            }
        }, nil, nil)
        // swiftlint:enable multiline_arguments
    }

    // MARK: - Querying

    /// Simply executes a statement with a success / failure result.
    ///
    /// - Parameter query: The SQL statement to execute
    ///
    /// - Throws: `StructureError.InternalError` if the execution failed.
    public func execute(query: String) throws {
        var errorMessage: UnsafeMutablePointer<Int8>? = nil
        let result = sqlite3_exec(db, query, nil, nil, &errorMessage)

        var potentialError: RestructureError? = nil

        if result != SQLITE_OK, let rawMessage = errorMessage {
            if let message = String(validatingCString: rawMessage) {
                potentialError = RestructureError.internalError(result, message)
            }

            sqlite3_free(errorMessage)
        }

        if let error = potentialError {
            throw error
        }
    }

    /// Prepare a new `Statement` for the database
    ///
    /// - Parameter query: The SQL statement to prepare
    ///
    /// - Throws: `StructureError.InternalError` if the statement cannot be parsed.
    ///
    /// - Returns: An unexecuted, unbound statement.
    public func prepare(query: String) throws -> Statement {
        let statement = try Statement(restructure: self, query: query)
        statement.arrayStrategy = arrayStrategy
        statement.dateStrategy = dateStrategy

        preparedStatements.insert(statement.statement)

        return statement
    }

    func finalize(statement: Statement) {
        guard preparedStatements.contains(statement.statement) else { return }

        preparedStatements.remove(statement.statement)

        let result = sqlite3_finalize(statement.statement)

        if result != SQLITE_OK {
            let error = RestructureError.from(result: result)
            fatalError("Failed to finalize the statement: \(error)")
        }
    }

    // MARK: - Transactions

    /// Start a transaction for the database
    public func beginTransaction() {
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
    }

    /// Commit a transaction for the database
    public func commitTransaction() {
        sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil)
    }

    /// Rollback a transaction for the database
    public func rollbackTransaction() {
        sqlite3_exec(db, "ROLLBACK TRANSACTION", nil, nil, nil)
    }

    /// Perform the given block in a transaction, rolling back on an error.
    ///
    /// - Parameter transactionBlock: A block of statements to perform in a transaction.
    ///
    /// - Throws: An `Error` if the block throws, which results in rolling back any statements in the transaction.
    public func transaction(_ transactionBlock: (Restructure) throws -> Void) throws {
        var potentialError: Error? = nil

        beginTransaction()

        do {
            try transactionBlock(self)
            commitTransaction()
        } catch {
            potentialError = error
            rollbackTransaction()
        }

        if let error = potentialError {
            throw error
        }
    }

    // MARK: - Migration

    /// Does the database need migrated to the target version?
    ///
    /// - Parameter targetVersion: The target migration version to test for.
    ///
    /// - Returns: `true` if the database would need migrated, otherwise `false`.
    public func needsMigration(targetVersion: Int) -> Bool {
        userVersion < targetVersion
    }

    /// Perform a schema migration, if applicable.
    ///
    /// - Parameter version: The version of the given migration, to determine whether the migration should be run.
    ///
    /// - Parameter migration: A block of statements to perform the migration.
    ///
    /// - Throws: An `Error` if the migration failed, or was performed out of order.
    ///
    /// - Note: Migrations affect the `userVersion` of the database. Migrations that have already run are ignored.
    public func migrate(version: Int, migration: (Restructure) throws -> Void) throws {
        // Skip if this migration has already run
        guard userVersion < version else {
            return
        }

        // Ensure this is the next migration
        guard version - userVersion == 1 else {
            throw RestructureError.error("Attemped migration \(version) is out of order with \(userVersion)")
        }

        // Run the migrations in a transaction
        try transaction { try migration($0) }

        // Increment the user version on success
        userVersion += 1
    }

    // MARK: - Utilities

    /// Get a value for a given pragma
    private func get<T: PragmaRepresentable>(pragma: String) -> T {
        do {
            let statement = try prepare(query: "PRAGMA \(pragma)")
            let result = statement.step()

            switch result {
            case let .row(row):
                return T.from(value: row[0])
            default:
                fatalError("Failed to fetch \(pragma) pragma from a result: \(result)")
            }
        } catch {
            fatalError("Failed to fetch \(pragma) pragma: \(error)")
        }
    }

    /// Set the value of a pragma
    private func set<T: PragmaRepresentable>(pragma: String, value: T) {
        let result = sqlite3_exec(db, "PRAGMA \(pragma) = \(value.pragmaValue)", nil, nil, nil)

        if result != SQLITE_OK {
            let error = RestructureError.from(result: result)
            fatalError("Failed to set \(pragma): \(error)")
        }
    }

    /// Send an incremental vacuum request to clean the given amount of pages
    public func incrementalVacuum(pages: Int = 0) {
        let query: String

        if pages < 1 {
            query = "PRAGMA incremental_vacuum"
        } else {
            query = "PRAGMA incremental_vacuum(\(pages))"
        }

        let result = sqlite3_exec(db, query, nil, nil, nil)

        if result != SQLITE_OK {
            let error = RestructureError.from(result: result)
            fatalError("Failed to incremental vacuum: \(error)")
        }
    }

    /// Perform a vacuum operation on the database.
    public func vacuum() {
        let result = sqlite3_exec(db, "VACUUM", nil, nil, nil)

        if result != SQLITE_OK {
            let error = RestructureError.from(result: result)
            fatalError("Failed to vacuum: \(error)")
        }
    }

    /// Set the write-ahead log mode.
    public func walCheckpoint(mode: WalCheckpointMode) {
        let result = sqlite3_wal_checkpoint_v2(db, nil, mode.value, nil, nil)

        if result != SQLITE_OK {
            let error = RestructureError.from(result: result)
            fatalError("Failed to perform WAL checkpoint: \(error)")
        }
    }
}
