// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation
import XCTest

@testable import Path

final class PathStandardPathsTests: XCTestCase {
  func test_standardUnixPaths() {
    XCTAssertEqual(Path.root.string, "/")
    XCTAssertEqual(Path.usr.string, "/usr")
    XCTAssertEqual(Path.bin.string, "/usr/bin")
    XCTAssertEqual(Path.local.string, "/usr/local")
    XCTAssertEqual(Path.localBin.string, "/usr/local/bin")
  }
}
