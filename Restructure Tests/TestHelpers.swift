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
