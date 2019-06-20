//
//  TestHelpers.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/4/18.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import XCTest

func XCTSuccess() {
    XCTAssertTrue(true)
}

func XCTSuccess(_ message: String) {
    XCTAssertTrue(true, message)
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
