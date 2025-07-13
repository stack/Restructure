//
//  RestructureInitializationTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/4/18.
//  SPDX-License-Identifier: MIT
//

import Foundation
import Testing

@testable import Restructure

final class RestructureInitializationTests {

    var restructure: Restructure? = nil
    var tempPath: String = ""

    init() {
        tempPath = testPath(description: "Initialization Tests")
    }

    deinit {
        restructure?.close()
        try? FileManager.default.removeItem(atPath: tempPath)
    }

    @Test func createInMemoryWorks() throws {
        restructure = try Restructure()
    }

    @Test func createFileWorks() throws {
        restructure = try Restructure(path: tempPath)
    }

    @Test func createExistingFileWorks() throws {
        // Build the first time
        restructure = try Restructure(path: tempPath)
        restructure?.close()
        restructure = nil

        // Attempt to run again
        restructure = try Restructure(path: tempPath)
    }
}

final class RestructurePropertiesTests {

    var restructure: Restructure
    var tempPath: String = ""

    init() throws {
        tempPath = testPath(description: "Initialization Tests")
        restructure = try Restructure(path: tempPath)
    }

    deinit {
        restructure.close()
        try? FileManager.default.removeItem(atPath: tempPath)
    }

    @Test func journalModeDefault() throws {
        #expect(restructure.journalMode == .wal)
        restructure.close()

        restructure = try Restructure()
        #expect(restructure.journalMode == .memory)
    }

    @Test(arguments: JournalMode.allCases)
    func journalModeSettable(mode: JournalMode) throws {
        restructure = try Restructure(path: tempPath, journalMode: mode)
        #expect(restructure.journalMode == mode)
        restructure.close()
    }

    @Test(arguments: SecureDelete.allCases)
    func secureDeleteSettable(mode: SecureDelete) throws {
        restructure.secureDelete = mode
        #expect(restructure.secureDelete == mode)
        restructure.close()
    }

    @Test(arguments: AutoVacuum.allCases)
    func autoVacuumSettable(mode: AutoVacuum) throws {
        restructure = try Restructure(path: tempPath)
        restructure.autoVacuum = mode
        restructure.vacuum()

        #expect(restructure.autoVacuum == mode)

        restructure.close()
    }

    @Test func incrementalAutoVacuum() throws {
        restructure.autoVacuum = .incremental
        restructure.vacuum()

        restructure.incrementalVacuum()
        restructure.incrementalVacuum(pages: 2)

        restructure.close()
    }
}

func testLocalRoot() -> URL {
    let tempPath = NSTemporaryDirectory()
    let tempUrl = URL(fileURLWithPath: tempPath)

    return tempUrl
}

func testPath(description: String) -> String {
    return testURL(description: description).path
}

func testURL(description: String) -> URL {
    let uuid = UUID().uuidString
    let uniqueName = "Restructure \(description) \(uuid).data"

    return testLocalRoot().appendingPathComponent(uniqueName)
}
