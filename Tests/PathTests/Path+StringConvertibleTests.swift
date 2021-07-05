// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation
import XCTest

@testable import Path

final class PathStringConvertibleTests: XCTestCase {
    func test_customStringConvertible() {
        XCTAssertEqual(String(describing: Path.root), "/")
        XCTAssertEqual(String(describing: Path("/path/to/file")), "/path/to/file")
    }

    func test_customDebugStringConvertible() {
        XCTAssertEqual(String(reflecting: Path.root), "<Path: \"/\">")
        XCTAssertEqual(String(reflecting: Path("/path/to/file")), "<Path: \"/path/to/file\">")
    }
}
